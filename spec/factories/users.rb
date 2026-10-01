FactoryBot.define do
  factory :user do
    organization
    sequence(:name) { |number| "Seller #{number}" }
    sequence(:email) { |number| "seller-#{number}@example.test" }
    role { :seller }
    active { true }
  end
end
