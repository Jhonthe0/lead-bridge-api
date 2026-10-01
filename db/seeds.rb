organization = Organization.find_or_create_by!(slug: "acme") do |record|
  record.name = "Acme Comercial"
end

admin = organization.users.find_or_create_by!(email: "admin@acme.test") do |record|
  record.name = "Admin Acme"
  record.role = :admin
end

seller = organization.users.find_or_create_by!(email: "seller@acme.test") do |record|
  record.name = "Vendedor Acme"
  record.role = :seller
end

development_token = ENV.fetch("SEED_DEVICE_TOKEN", "development-device-token")
Device.find_or_create_by!(device_uuid: "00000000-0000-4000-8000-000000000001") do |record|
  record.organization = organization
  record.user = seller
  record.name = "Android de desenvolvimento"
  record.platform = "android"
  record.app_version = "0.1.0"
  record.token_digest = Device.token_digest_for(development_token)
end

[
  { name: "João da Silva", phone: "5511999990001", company_name: "Mercado João" },
  { name: "Maria Oliveira", phone: "5511999990002", company_name: "Loja Maria" }
].each do |attributes|
  organization.customers.find_or_create_by!(phone: attributes[:phone]) do |record|
    record.assign_attributes(attributes)
  end
end

puts "Seeded #{organization.name} with users #{admin.email} and #{seller.email}."
puts "Development device token: #{development_token}"
