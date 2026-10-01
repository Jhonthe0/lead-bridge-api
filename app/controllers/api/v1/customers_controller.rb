module Api
  module V1
    class CustomersController < BaseController
      def index
        render_customer_page(customer_catalog.call)
      end

      def search
        render_customer_page(customer_catalog(search_term: params[:q]).call)
      end

      def show
        customer = current_organization.customers.find(params[:id])
        render json: { customer: CustomerSerializer.render(customer) }
      end

      def create
        customer = current_organization.customers.create!(customer_params)
        render json: { customer: CustomerSerializer.render(customer) }, status: :created
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :phone, :company_name, :external_crm_id, metadata: {})
      end

      def customer_catalog(search_term: nil)
        Customers::CatalogQuery.new(
          organization: current_organization,
          search_term:,
          page_number: params[:page_number],
          items_per_page: params[:items_per_page]
        )
      end

      def render_customer_page(page)
        render json: {
          customers: page.records.map { CustomerSerializer.render(_1) },
          pagination: page.to_h.except(:records)
        }
      end
    end
  end
end
