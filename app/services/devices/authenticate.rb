module Devices
  class Authenticate
    def initialize(token:)
      @token = token.to_s
    end

    # Finds an active device whose user and organization are also active.
    # Example: Devices::Authenticate.new(token: bearer_token).call
    def call
      return if token.blank?

      Device.joins(user: :organization).find_by(
        token_digest: Device.token_digest_for(token),
        active: true,
        users: { active: true },
        organizations: { active: true }
      )
    end

    private

    attr_reader :token
  end
end
