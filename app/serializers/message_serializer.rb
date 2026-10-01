class MessageSerializer
  ATTRIBUTES = %i[
    id sender_type content_type body occurred_at external_identifier metadata created_at updated_at
  ].freeze

  # Builds the stable JSON representation exposed by the message API.
  # Example: MessageSerializer.render(message)
  def self.render(message)
    message.as_json(only: ATTRIBUTES)
  end
end
