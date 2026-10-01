module Api
  module V1
    class BaseController < ApplicationController
      MAX_REQUEST_BYTES = 1.megabyte

      before_action :reject_oversized_request!
      before_action :authenticate_device!

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
      rescue_from ActionController::ParameterMissing, with: :render_invalid_request
      rescue_from Captures::Create::InvalidCapture, with: :render_invalid_capture

      private

      attr_reader :current_device

      def current_organization
        current_device.organization
      end

      def current_user
        current_device.user
      end

      def authenticate_device!
        return render_api_error(:authentication_required, :unauthorized) if bearer_token.blank?

        @current_device = Devices::Authenticate.new(token: bearer_token).call
        return render_api_error(:invalid_token, :unauthorized) unless current_device

        current_device.touch(:last_seen_at)
      end

      def bearer_token
        authorization_header = request.headers["Authorization"].to_s
        authorization_header[/\ABearer\s+(.+)\z/i, 1]
      end

      def reject_oversized_request!
        return if request.content_length.to_i <= MAX_REQUEST_BYTES

        render_api_error(:payload_too_large, :payload_too_large)
      end

      def render_not_found(_error)
        render_api_error(:not_found, :not_found)
      end

      def render_record_invalid(error)
        render_api_error(:unprocessable_entity, :unprocessable_entity, error.record.errors.full_messages)
      end

      def render_invalid_request(error)
        render_api_error(:invalid_request, :bad_request, [ error.message ])
      end

      def render_invalid_capture(error)
        render_api_error(:invalid_capture, :unprocessable_entity, error.details)
      end

      def render_api_error(code, status, details = [])
        render json: {
          error: { code:, message: I18n.t("api.errors.#{code}"), details: Array(details) }
        }, status:
      end
    end
  end
end
