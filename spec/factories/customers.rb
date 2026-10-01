FactoryBot.define do
  factory :customer do
    organization
    sequence(:name) { |number| "Customer #{number}" }
    sequence(:phone) { |number| "55119999#{number.to_s.rjust(4, '0')}" }
    metadata { {} }
  end
end
