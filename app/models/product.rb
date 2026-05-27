class Product < ApplicationRecord
  belongs_to :platform
  belongs_to :category, optional: true
  has_many :prices, dependent: :destroy

  validates :name, :link, presence: true
  validates :link, uniqueness: { scope: :platform_id }

  def current_price
    prices.order(recorded_at: :desc).first&.amount
  end

  def price_history
    prices.order(recorded_at: :asc)
  end
end
