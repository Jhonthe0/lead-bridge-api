FactoryBot.define do
  factory :organization do
    sequence(:name) { |number| "Organization #{number}" }
    sequence(:slug) { |number| "organization-#{number}" }
    active { true }
  end
end
