class GroupsController < ApplicationController
  def index
    groups = ProductGroup.all
    render json: {
      brand_groups: ProductGroup.brand_groups.as_json(only: [:id, :name, :slug]),
      category_groups: ProductGroup.category_groups.as_json(only: [:id, :name, :slug])
    }
  end

  def show
    group = ProductGroup.find_by(slug: params[:slug])
    render json: {
      group: group.as_json(only: [:id, :name, :slug, :group_type]),
      price_comparison: group.price_comparison,
      products: group.products.includes(:platform).map do |p|
        {
          id: p.id,
          name: p.name,
          platform: p.platform.slug,
          price: p.current_price&.amount,
          link: p.link,
          rating: p.rating,
          image_url: p.image_url
        }
      end
    }
  end
end