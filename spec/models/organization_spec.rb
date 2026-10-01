require "rails_helper"

RSpec.describe Organization do
  it "creates an active organization with a normalized slug" do
    organization = described_class.create!(name: "Acme", slug: " ACME-Brazil ")

    expect(organization).to be_active
    expect(organization.slug).to eq("acme-brazil")
  end

  it "rejects duplicate slugs" do
    create(:organization, slug: "duplicate-slug")
    duplicate = build(:organization, slug: "DUPLICATE-SLUG")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:slug]).to include("has already been taken")
  end
end
