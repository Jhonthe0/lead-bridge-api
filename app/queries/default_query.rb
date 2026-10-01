class DefaultQuery
  DEFAULT_ITEMS_PER_PAGE = 25
  MAX_ITEMS_PER_PAGE = 100

  def initialize(page_number: 1, items_per_page: DEFAULT_ITEMS_PER_PAGE)
    @page_number = positive_integer(page_number, fallback: 1)
    @items_per_page = positive_integer(items_per_page, fallback: DEFAULT_ITEMS_PER_PAGE)
    @items_per_page = [ @items_per_page, MAX_ITEMS_PER_PAGE ].min
  end

  private

  attr_reader :items_per_page, :page_number

  def paginate_query(relation)
    relation.limit(items_per_page).offset((page_number - 1) * items_per_page)
  end

  def positive_integer(value, fallback:)
    parsed_value = Integer(value, exception: false)
    return fallback if parsed_value.blank? || parsed_value < 1

    parsed_value
  end
end
