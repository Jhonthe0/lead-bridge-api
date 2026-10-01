require "rails_helper"

RSpec.describe User do
  it "associates a seller with one organization" do
    organization = create(:organization)
    user = create(:user, organization:)

    expect(user.organization).to eq(organization)
    expect(user).to be_seller
    expect(organization.users).to contain_exactly(user)
  end

  it "normalizes email before enforcing tenant uniqueness" do
    organization = create(:organization)
    create(:user, organization:, email: "seller@example.test")
    duplicate = build(:user, organization:, email: " SELLER@example.test ")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end
end
