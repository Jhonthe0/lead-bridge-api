module Api
  module V1
    class MessagesController < BaseController
      def create
        conversation = current_organization.conversations.find(params[:conversation_id])
        message = conversation.messages.create!(message_attributes)

        render json: { message: MessageSerializer.render(message) }, status: :created
      end

      private

      def message_params
        params.require(:message).permit(
          :sender_type, :content_type, :body, :occurred_at, :external_identifier, metadata: {}
        )
      end

      def message_attributes
        message_params.to_h.merge(organization: current_organization)
      end
    end
  end
end
