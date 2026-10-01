module Devices
  class Register
    InvalidRegistrationToken = Class.new(StandardError)
    InvalidDeviceOwner = Class.new(StandardError)

    Result = Data.define(:device, :token)

    def initialize(attributes:, registration_token:, expected_registration_token:)
      @attributes = attributes.deep_symbolize_keys
      @registration_token = registration_token.to_s
      @expected_registration_token = expected_registration_token.to_s
    end

    # Registers or refreshes one Android device and returns its one-time token.
    # Example: Devices::Register.new(attributes:, registration_token:, expected_registration_token:).call
    def call
      validate_registration_token!
      user = active_user
      device = find_or_initialize_device(user)
      token, token_digest = Device.generate_token_pair
      device.update!(device_attributes(user, token_digest))

      Result.new(device:, token:)
    end

    private

    attr_reader :attributes, :expected_registration_token, :registration_token

    def validate_registration_token!
      supplied_digest = Digest::SHA256.hexdigest(registration_token)
      expected_digest = Digest::SHA256.hexdigest(expected_registration_token)
      valid = expected_registration_token.present? && ActiveSupport::SecurityUtils.secure_compare(supplied_digest, expected_digest)

      return if valid

      raise InvalidRegistrationToken, "registration_token=[FILTERED]; expected the configured provisioning secret"
    end

    def active_user
      User.joins(:organization).find_by!(
        id: attributes.fetch(:user_id),
        active: true,
        organizations: { active: true }
      )
    end

    def find_or_initialize_device(user)
      device = Device.find_or_initialize_by(device_uuid: attributes.fetch(:device_uuid))
      owner_matches = device.new_record? || device.user_id == user.id
      unless owner_matches
        detail = "device_uuid=#{attributes[:device_uuid].inspect}; expected an unregistered device or the existing owner"
        raise InvalidDeviceOwner, detail
      end

      device
    end

    def device_attributes(user, token_digest)
      attributes.slice(:device_uuid, :name, :platform, :app_version).merge(
        organization: user.organization,
        user:,
        token_digest:,
        active: true,
        last_seen_at: Time.current
      )
    end
  end
end
