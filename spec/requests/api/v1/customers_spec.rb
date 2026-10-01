require "rails_helper"

RSpec.describe "Customers API" do
  let(:token) { "device-token" }
  let!(:device) do
    create(:device, token_digest: Device.token_digest_for(token))
  end
  let(:headers) do
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  it "creates a customer inside the authenticated organization" do
    payload = { customer: { name: "João", phone: "+55 (11) 99999-0001" } }

    post "/api/v1/customers", params: payload.to_json, headers: headers

    expect(response).to have_http_status(:created)
    customer = Customer.find(JSON.parse(response.body).dig("customer", "id"))
    expect(customer.organization).to eq(device.organization)
    expect(customer.phone).to eq("5511999990001")
  end

  it "does not expose a customer from another organization" do
    foreign_customer = create(:customer)

    get "/api/v1/customers/#{foreign_customer.id}", headers: headers

    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body).dig("error", "code")).to eq("not_found")
  end
end
