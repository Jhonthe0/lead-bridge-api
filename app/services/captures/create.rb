require "time"

module Captures
  class Create
    MAX_MESSAGES = 500

    InvalidCapture = Class.new(StandardError) do
      attr_reader :details

      def initialize(details)
        @details = Array(details)
        super("Invalid capture: #{@details.join('; ')}; expected a complete capture payload")
      end
    end

    Result = Data.define(:conversation, :messages_created, :duplicate)

    def initialize(device:, attributes:, customer_finder: Customers::FindOrCreate)
      @device = device
      @attributes = attributes.deep_symbolize_keys
      @customer_finder = customer_finder
    end

    # Persists a complete capture atomically and safely handles retries.
    # Example: Captures::Create.new(device:, attributes:).call
    def call
      validate_payload!
      existing_conversation = Conversation.find_by(capture_uuid: attributes[:capture_uuid])
      return duplicate_result(existing_conversation) if existing_conversation

      create_capture
    rescue ActiveRecord::RecordNotUnique
      duplicate_after_race!
    rescue KeyError, ArgumentError => error
      detail = "payload_keys=#{attributes.keys.inspect}; expected required fields with ISO 8601 timestamps (#{error.message})"
      raise InvalidCapture, detail
    end

    private

    attr_reader :attributes, :customer_finder, :device

    def validate_payload!
      errors = []
      errors << "capture_uuid=#{attributes[:capture_uuid].inspect}; expected an RFC 4122 UUID" unless valid_capture_uuid?
      errors << "contact.display_name=#{contact[:display_name].inspect}; expected a non-empty string" if contact[:display_name].blank?
      errors << invalid_messages_detail unless valid_messages?
      raise InvalidCapture, errors if errors.any?
    end

    def valid_capture_uuid?
      attributes[:capture_uuid].to_s.match?(Conversation::UUID_FORMAT)
    end

    def valid_messages?
      messages.is_a?(Array) && messages.length.between?(1, MAX_MESSAGES)
    end

    def invalid_messages_detail
      message_count = messages.respond_to?(:length) ? messages.length : "unknown"
      "messages=#{messages.class}(length=#{message_count}); expected an Array with 1..#{MAX_MESSAGES} items"
    end

    def create_capture
      conversation = nil
      ActiveRecord::Base.transaction do
        customer = customer_finder.new(organization:, contact:).call
        conversation = create_conversation(customer)
        create_messages(conversation)
      end

      Result.new(conversation:, messages_created: messages.length, duplicate: false)
    end

    def create_conversation(customer)
      organization.conversations.create!(
        customer:,
        user: device.user,
        device:,
        capture_uuid: attributes.fetch(:capture_uuid),
        captured_at: parse_time(attributes.fetch(:captured_at)),
        source: attributes.fetch(:source, "whatsapp_business"),
        external_identifier: attributes[:external_identifier],
        metadata: attributes.fetch(:metadata, {})
      )
    end

    def create_messages(conversation)
      messages.each do |message_attributes|
        conversation.messages.create!(message_params(message_attributes))
      end
    end

    def message_params(message_attributes)
      message = message_attributes.deep_symbolize_keys
      {
        organization:,
        sender_type: message.fetch(:sender_type),
        content_type: message.fetch(:content_type, "text"),
        body: message.fetch(:body),
        occurred_at: parse_time(message.fetch(:occurred_at)),
        external_identifier: message[:temporary_id] || message[:external_identifier],
        metadata: message.fetch(:metadata, {})
      }
    end

    def duplicate_after_race!
      conversation = Conversation.find_by(capture_uuid: attributes[:capture_uuid])
      return duplicate_result(conversation) if conversation

      raise
    end

    def duplicate_result(conversation)
      unless conversation.organization_id == organization.id
        detail = "capture_uuid=#{attributes[:capture_uuid].inspect}; expected a UUID unused by another organization"
        raise InvalidCapture, detail
      end

      Result.new(conversation:, messages_created: 0, duplicate: true)
    end

    def parse_time(value)
      Time.iso8601(value.to_s)
    end

    def organization
      device.organization
    end

    def contact
      @contact ||= attributes.fetch(:contact, {}).deep_symbolize_keys
    end

    def messages
      @messages ||= attributes.fetch(:messages, [])
    end
  end
end
