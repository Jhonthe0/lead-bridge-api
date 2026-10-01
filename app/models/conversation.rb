class Conversation < ApplicationRecord
  UUID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

  belongs_to :organization
  belongs_to :customer
  belongs_to :user
  belongs_to :device

  has_many :messages, dependent: :destroy

  enum :source, { whatsapp_business: "whatsapp_business" }, validate: true

  validates :capture_uuid, :captured_at, presence: true
  validates :capture_uuid, uniqueness: true, format: { with: UUID_FORMAT }
  validate :associations_belong_to_organization

  private

  def associations_belong_to_organization
    validate_organization_for(:customer)
    validate_organization_for(:user)
    validate_organization_for(:device)
  end

  def validate_organization_for(association_name)
    association = public_send(association_name)
    return if association.blank? || association.organization_id == organization_id

    errors.add(association_name, :invalid)
  end
end
