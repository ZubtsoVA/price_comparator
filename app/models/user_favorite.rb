class UserFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :product
  validates :user_id, uniqueness: { scope: :product_id }

  scope :with_notifications, -> { where(notify_on_price_drop: true) }
  scope :ordered_by_priority, -> { order(priority: :desc, created_at: :desc) }

  def check_price_alert
    return unless notify_on_price_drop && target_price.present?

    current_price = product.current_price&.amount
    if current_price && current_price <= target_price
      update(notify_on_price_drop: false)
      true
    else
      false
    end
  end
end
