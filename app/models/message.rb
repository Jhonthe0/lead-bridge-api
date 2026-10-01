class Message < ApplicationRecord
  belongs_to :organization
  belongs_to :conversation

  enum :sender_type, {
    customer: "customer",
    seller: "seller",
    unknown: "unknown"
  }, validate: true, prefix: true
  enum :content_type, {
    text: "text",
    image: "image",
    audio: "audio",
    document: "document",
    unknown: "unknown"
  }, validate: true, prefix: true

  validates :body, presence: true, length: { maximum: 10_000 }
  validates :occurred_at, presence: true
  validates :external_identifier, uniqueness: { scope: :conversation_id }, allow_blank: true
  validate :conversation_belongs_to_organization

  private

  def conversation_belongs_to_organization
    return if conversation.blank? || conversation.organization_id == organization_id

    errors.add(:conversation, :invalid)
  end
end
