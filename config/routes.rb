Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Фронтенд
  root "pages#index"

  # Поиск
  get "/search", to: "searches#show"

  post "/cache/clear", to: "searches#clear_cache"

  # История цен
  get "/products/:id/price_history", to: "products#price_history"
end