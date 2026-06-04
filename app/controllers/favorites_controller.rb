class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    favorites = current_user.favorites
                            .includes(:product)
                            .ordered_by_priority

    render json: favorites.map { |f| favorite_json(f) }
  end

  def create
    product = Product.find(params[:product_id])

    favorite = current_user.add_to_favorites(
      product,
      priority: params[:priority] || 0,
      notes: params[:notes],
      notify: params[:notify_on_price_drop] || false,
      target_price: params[:target_price]
    )

    if favorite.persisted?
      render json: favorite_json(favorite), status: :created
    else
      render json: { errors: favorite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    render json: { message: "Removed from favorites" }
  end

  def check_alerts
    favorites = current_user.favorites.with_notifications

    triggered = []
    favorites.each do |favorite|
      if favorite.check_price_alert
        triggered << favorite.product_id
      end
    end

    render json: {
      checked: favorites.count,
      triggered: triggered
    }
  end

  private

  def favorite_json(favorite)
    {
      id: favorite.id,
      product: {
        id: favorite.product.id,
        name: favorite.product.name,
        platform: favorite.product.platform.slug,
        price: favorite.product.current_price&.amount,
        image_url: favorite.product.image_url,
        rating: favorite.product.rating,
        link: favorite.product.link
      },
      notes: favorite.notes,
      priority: favorite.priority,
      notify_on_price_drop: favorite.notify_on_price_drop,
      target_price: favorite.target_price,
      created_at: favorite.created_at
    }
  end
end