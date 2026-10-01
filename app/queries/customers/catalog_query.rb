module Customers
  class CatalogQuery < DefaultQuery
    Result = Data.define(:records, :page_number, :items_per_page, :total_items, :total_pages)

    def initialize(organization:, search_term: nil, page_number: 1, items_per_page: DEFAULT_ITEMS_PER_PAGE)
      super(page_number:, items_per_page:)
      @organization = organization
      @search_term = search_term.to_s.strip
    end

    # Returns a tenant-scoped customer page and its pagination metadata.
    # Example: Customers::CatalogQuery.new(organization:).call
    def call
      total_items = base_query.count
      records = paginate_query(base_query.order(created_at: :desc))

      Result.new(records:, page_number:, items_per_page:, total_items:, total_pages: total_pages(total_items))
    end

    private

    attr_reader :organization, :search_term

    def base_query
      @base_query ||= filter_by_search_term(organization.customers)
    end

    def filter_by_search_term(relation)
      return relation if search_term.blank?

      escaped_term = ActiveRecord::Base.sanitize_sql_like(search_term)
      relation.where(
        "name ILIKE :term OR phone ILIKE :term OR company_name ILIKE :term OR external_crm_id ILIKE :term",
        term: "%#{escaped_term}%"
      )
    end

    def total_pages(total_items)
      (total_items.to_f / items_per_page).ceil
    end
  end
end
