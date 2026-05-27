Rails.application.routes.draw do
  # Фронтенд
  root "pages#index"

  # Поиск
  get  "/search",      to: "searches#show"
  post "/cache/clear", to: "searches#clear_cache"

  # История цен
  get "/products/:id/price_history", to: "products#price_history"
end