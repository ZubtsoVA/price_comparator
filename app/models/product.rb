class Product < ApplicationRecord
  belongs_to :platform
  belongs_to :category, optional: true
  belongs_to :product_group, optional: true
  has_many :favorites, class_name: 'UserFavorite'
  has_many :prices, dependent: :destroy

  before_save :normalize_name, :extract_brand, :extract_external_id

  validates :name, :link, presence: true
  validates :link, uniqueness: { scope: :platform_id }

  def current_price
    prices.order(recorded_at: :desc).first&.amount
  end

  def price_history
    prices.order(recorded_at: :asc)
  end

  def similar_on_other_platforms
    return [] unless product_group
    product_group.products.where.not(id: id)
  end

  def price_comparison
    return nil unless product_group
    product_group.price_comparison
  end

  private

  def normalize_name
    return if name.blank?

    normalized = name.downcase
    normalized = normalized.gsub(/\b(?:s|m|l|xl|xxl|xxxl)\b/i, '')
    normalized = normalized.gsub(/\b\d{2,3}\b/, '')
    normalized = normalized.gsub(/\b(?:арт|art|id|sku)[:\s]+\w+\b/i, '')
    normalized = normalized.gsub(/[^\w\s]/, '')
    normalized = normalized.gsub(/\s+/, ' ').strip

    self.normalized_name = normalized
  end

  def extract_brand
    return if name.blank?

    common_brands = ['adidas', 'nike', 'puma', 'rebook', 'new balance',
                     'timberland', 'ecco', 'skechers', 'columbia', 'north face',
                     'asics', 'mizuno', 'converse', 'vans', 'tommy hilfiger',
                     'calvin klein', 'lacoste', 'boss', 'armani', 'gucci',
                     'prada', 'zara', 'hm', 'uniqlo', 'indefini', 'tendance']

    name_lower = name.downcase
    found_brand = common_brands.find { |brand| name_lower.include?(brand) }

    if found_brand
      self.brand = found_brand.titleize
    elsif name.present? && name.split.first =~ /^[A-ZА-Я]/
      self.brand = name.split.first
    end
  end
  def extract_external_id
    return if link.blank?

    case platform&.slug
    when 'wb'
      if match = link.match(/catalog\/(\d+)/)
        self.external_id = match[1]
      end
    when 'lamoda'
      if match = link.match(/\/p\/([^\/]+)/)
        self.external_id = match[1]
      end
    end
  end
end
