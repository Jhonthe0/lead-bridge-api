require "rails_helper"

RSpec.describe "Devices API" do
  let(:user) { create(:user) }
  let(:headers) do
    {
      "Content-Type" => "application/json",
      "X-Registration-Token" => "provision-secret"
    }
  end
  let(:payload) do
    {
      device: {
        user_id: user.id,
        device_uuid: SecureRandom.uuid,
        name: "Galaxy S25",
        platform: "android",
        app_version: "1.0.0"
      }
    }
  end

  around do |example|
    previous_secret = Rails.application.config.x.device_registration_secret
    Rails.application.config.x.device_registration_secret = "provision-secret"
    example.run
  ensure
    Rails.application.config.x.device_registration_secret = previous_secret
  end

  it "registers a device and returns its one-time bearer token" do
    post "/api/v1/devices/register", params: payload.to_json, headers: headers

    response_json = JSON.parse(response.body)
    device = Device.find(response_json.dig("device", "id"))
    expect(response).to have_http_status(:created)
    expect(device.organization).to eq(user.organization)
    expect(device.token_digest).to eq(Device.token_digest_for(response_json.fetch("token")))
  end
end
