require "digest"
require "securerandom"

class Device < ApplicationRecord
  TOKEN_BYTES = 32

  belongs_to :organization
  belongs_to :user

  has_many :conversations, dependent: :restrict_with_exception

  validates :device_uuid, :name, :platform, :token_digest, presence: true
  validates :device_uuid, :token_digest, uniqueness: true
  validate :user_belongs_to_organization

  # Creates the one-time plaintext credential and its persistable digest.
  # Example: token, digest = Device.generate_token_pair
  def self.generate_token_pair
    token = SecureRandom.urlsafe_base64(TOKEN_BYTES)
    [ token, token_digest_for(token) ]
  end

  # Converts a bearer credential into the digest used for lookup.
  # Example: Device.token_digest_for("secret")
  def self.token_digest_for(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  private

  def user_belongs_to_organization
    return if user.blank? || user.organization_id == organization_id

    errors.add(:user, :invalid)
  end
end
