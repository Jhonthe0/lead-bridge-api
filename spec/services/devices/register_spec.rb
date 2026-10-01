require "rails_helper"

RSpec.describe Devices::Register do
  let(:user) { create(:user) }
  let(:attributes) do
    {
      user_id: user.id,
      device_uuid: SecureRandom.uuid,
      name: "Galaxy S25",
      platform: "android",
      app_version: "1.0.0"
    }
  end

  it "registers the device under the user's organization and issues an authentic token" do
    result = described_class.new(
      attributes:,
      registration_token: "provision-secret",
      expected_registration_token: "provision-secret"
    ).call

    expect(result.device.organization).to eq(user.organization)
    expect(result.device.token_digest).not_to eq(result.token)
    expect(Devices::Authenticate.new(token: result.token).call).to eq(result.device)
  end

  it "rejects an invalid provisioning credential" do
    registration = described_class.new(
      attributes:,
      registration_token: "wrong-secret",
      expected_registration_token: "provision-secret"
    )

    expect { registration.call }.to raise_error(described_class::InvalidRegistrationToken)
    expect(Device.count).to be_zero
  end
end
