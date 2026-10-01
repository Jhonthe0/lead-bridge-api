class CustomerSerializer
  ATTRIBUTES = %i[id name phone company_name external_crm_id metadata created_at updated_at].freeze

  # Builds the stable JSON representation exposed by the customer API.
  # Example: CustomerSerializer.render(customer)
  def self.render(customer)
    customer.as_json(only: ATTRIBUTES)
  end
end
