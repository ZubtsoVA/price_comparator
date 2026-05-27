class ProductsController < ApplicationController
  def price_history
    product = Product.find(params[:id])

    history = product.prices.history.map do |price|
      {
        amount: price.amount,
        platform: price.platform.name,
        recorded_at: price.recorded_at.iso8601
      }
    end

    render json: {
      product: {
        id: product.id,
        name: product.name,
        platform: product.platform.name
      },
      history: history
    }
  end
end