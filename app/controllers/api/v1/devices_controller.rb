module Api
  module V1
    class DevicesController < BaseController
      skip_before_action :authenticate_device!, only: :register

      rescue_from Devices::Register::InvalidRegistrationToken, with: :render_invalid_registration_token
      rescue_from Devices::Register::InvalidDeviceOwner, with: :render_invalid_device_owner

      def register
        result = Devices::Register.new(
          attributes: registration_params.to_h,
          registration_token: request.headers["X-Registration-Token"],
          expected_registration_token: Rails.application.config.x.device_registration_secret
        ).call

        render json: registration_json(result), status: :created
      end

      private

      def registration_params
        params.require(:device).permit(:user_id, :device_uuid, :name, :platform, :app_version)
      end

      def registration_json(result)
        {
          device: result.device.as_json(only: %i[id organization_id user_id device_uuid name platform app_version]),
          token: result.token
        }
      end

      def render_invalid_registration_token(_error)
        render_api_error(:invalid_registration_token, :unauthorized)
      end

      def render_invalid_device_owner(_error)
        render_api_error(:unprocessable_entity, :unprocessable_entity)
      end
    end
  end
end
