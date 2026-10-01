module Customers
  class FindOrCreate
    def initialize(organization:, contact:)
      @organization = organization
      @contact = contact.deep_symbolize_keys
    end

    # Resolves a customer inside one tenant, preferring stable identifiers.
    # Example: Customers::FindOrCreate.new(organization:, contact:).call
    def call
      existing_customer || organization.customers.create!(customer_attributes)
    end

    private

    attr_reader :contact, :organization

    def existing_customer
      customer_by_phone || customer_by_external_crm_id || customer_by_name
    end

    def customer_by_phone
      return if normalized_phone.blank?

      organization.customers.find_by(phone: normalized_phone)
    end

    def customer_by_external_crm_id
      return if contact[:external_crm_id].blank?

      organization.customers.find_by(external_crm_id: contact[:external_crm_id])
    end

    def customer_by_name
      organization.customers.where("LOWER(name) = ?", contact.fetch(:display_name).strip.downcase).first
    end

    def customer_attributes
      {
        name: contact.fetch(:display_name),
        phone: normalized_phone,
        company_name: contact[:company_name],
        external_crm_id: contact[:external_crm_id],
        metadata: contact.fetch(:metadata, {})
      }
    end

    def normalized_phone
      @normalized_phone ||= contact[:phone].to_s.gsub(/\D/, "").presence
    end
  end
end
