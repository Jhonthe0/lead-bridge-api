class User < ApplicationRecord
  belongs_to :organization

  has_many :devices, dependent: :restrict_with_exception
  has_many :conversations, dependent: :restrict_with_exception

  enum :role, { admin: "admin", seller: "seller" }, default: :seller, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :organization_id }
end
