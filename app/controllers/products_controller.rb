class ProductsController < ApplicationController
  def price_history

    product = Product.includes(prices: :platform).find(params[:id])

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