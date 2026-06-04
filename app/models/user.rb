class User < ApplicationRecord
  has_secure_password

  has_many :search_histories, dependent: :destroy
  has_many :favorites, class_name: 'UserFavorite', dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true,
            length: { minimum: 3, maximum: 50 }
  validates :role, inclusion: { in: %w[user admin] }

  scope :active, -> { where(active: true) }

  def admin?
    role == 'admin'
  end

  def record_search(query, results_count: 0, filters: nil, ip: nil, ua: nil)
    search_histories.create(
      query: query,
      normalized_query: normalize_query(query),
      results_count: results_count,
      filters_applied: filters,
      ip_address: ip,
      user_agent: ua,
      searched_at: Time.current
    )
  end

  def add_to_favorites(product, priority: 0, notes: nil, notify: false, target_price: nil)
    favorites.create(
      product: product,
      priority: priority,
      notes: notes,
      notify_on_price_drop: notify,
      target_price: target_price
    )
  end

  def recent_searches(limit = 10)
    search_histories.order(searched_at: :desc).limit(limit)
  end

  private

  def normalize_query(query)
    query.downcase.gsub(/[^\w\s]/, '').squish
  end
end