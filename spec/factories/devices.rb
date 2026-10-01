FactoryBot.define do
  factory :device do
    user
    organization { user.organization }
    device_uuid { SecureRandom.uuid }
    sequence(:name) { |number| "Android #{number}" }
    platform { "android" }
    app_version { "0.1.0" }
    token_digest { Device.token_digest_for(SecureRandom.urlsafe_base64(32)) }
    active { true }
  end
end
