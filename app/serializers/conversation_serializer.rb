class ConversationSerializer
  ATTRIBUTES = %i[
    id customer_id user_id device_id source external_identifier capture_uuid captured_at metadata created_at updated_at
  ].freeze

  # Builds a conversation response and optionally embeds ordered messages.
  # Example: ConversationSerializer.render(conversation, include_messages: true)
  def self.render(conversation, include_messages: false)
    result = conversation.as_json(only: ATTRIBUTES)
    return result unless include_messages

    result.merge("messages" => conversation.messages.order(:occurred_at).map { MessageSerializer.render(_1) })
  end
end
