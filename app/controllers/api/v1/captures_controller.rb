module Api
  module V1
    class CapturesController < BaseController
      def create
        result = Captures::Create.new(device: current_device, attributes: capture_params.to_h).call

        render json: capture_json(result), status: result.duplicate ? :ok : :created
      end

      private

      def capture_params
        params.permit(
          :capture_uuid, :captured_at, :source, :external_identifier,
          metadata: {},
          contact: %i[display_name phone company_name external_crm_id] + [ { metadata: {} } ],
          messages: %i[temporary_id external_identifier sender_type content_type body occurred_at] + [ { metadata: {} } ]
        )
      end

      def capture_json(result)
        {
          conversation_id: result.conversation.id,
          customer_id: result.conversation.customer_id,
          messages_created: result.messages_created,
          duplicate: result.duplicate
        }
      end
    end
  end
end
