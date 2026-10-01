Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "devices/register", to: "devices#register"

      resources :customers, only: %i[index show create] do
        get :search, on: :collection
      end

      resources :conversations, only: %i[create show] do
        resources :messages, only: :create
      end

      resources :captures, only: :create
    end
  end
end
