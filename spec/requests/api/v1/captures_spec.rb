require "rails_helper"

RSpec.describe "Captures API" do
  let(:token) { "device-token" }
  let!(:device) do
    create(:device, token_digest: Device.token_digest_for(token))
  end
  let(:headers) do
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end
  let(:capture_uuid) { SecureRandom.uuid }
  let(:payload) do
    {
      capture_uuid:,
      captured_at: "2026-10-01T12:30:00Z",
      source: "whatsapp_business",
      contact: { display_name: "João da Silva", phone: "+55 11 99999-0001" },
      messages: [
        {
          temporary_id: "local-001",
          sender_type: "customer",
          body: "Preciso de 200 unidades.",
          occurred_at: "2026-10-01T12:25:00Z"
        },
        {
          temporary_id: "local-002",
          sender_type: "seller",
          body: "Consigo entregar sexta.",
          occurred_at: "2026-10-01T12:26:00Z"
        }
      ]
    }
  end

  it "atomically creates the customer, conversation, and messages" do
    expect do
      post "/api/v1/captures", params: payload.to_json, headers: headers
    end.to change(Customer, :count).by(1)
      .and change(Conversation, :count).by(1)
      .and change(Message, :count).by(2)

    expect(response).to have_http_status(:created)
    response_json = JSON.parse(response.body)
    expect(response_json["messages_created"]).to eq(2)
    expect(Conversation.last.organization).to eq(device.organization)
    expect(Message.order(:occurred_at).pluck(:sender_type)).to eq(%w[customer seller])
  end

  it "returns the existing capture without duplicating records" do
    post "/api/v1/captures", params: payload.to_json, headers: headers
    conversation_id = JSON.parse(response.body).fetch("conversation_id")

    expect do
      post "/api/v1/captures", params: payload.to_json, headers: headers
    end.not_to change { [ Customer.count, Conversation.count, Message.count ] }

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include(
      "conversation_id" => conversation_id,
      "messages_created" => 0,
      "duplicate" => true
    )
  end

  it "rejects authentication with an unknown device token" do
    post "/api/v1/captures",
      params: payload.to_json,
      headers: headers.merge("Authorization" => "Bearer unknown")

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body).dig("error", "code")).to eq("invalid_token")
  end
end
