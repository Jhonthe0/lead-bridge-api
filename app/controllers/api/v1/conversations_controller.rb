module Api
  module V1
    class ConversationsController < BaseController
      def create
        customer = current_organization.customers.find(conversation_params.fetch(:customer_id))
        conversation = current_organization.conversations.create!(conversation_attributes(customer))

        render json: { conversation: ConversationSerializer.render(conversation) }, status: :created
      end

      def show
        conversation = current_organization.conversations.find(params[:id])
        render json: { conversation: ConversationSerializer.render(conversation, include_messages: true) }
      end

      private

      def conversation_params
        params.require(:conversation).permit(
          :customer_id, :source, :external_identifier, :capture_uuid, :captured_at, metadata: {}
        )
      end

      def conversation_attributes(customer)
        conversation_params.except(:customer_id).to_h.merge(
          customer:,
          user: current_user,
          device: current_device,
          capture_uuid: conversation_params[:capture_uuid].presence || SecureRandom.uuid
        )
      end
    end
  end
end
