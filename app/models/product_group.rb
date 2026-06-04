class ProductGroup < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :canonical_name, presence: true

  def self.find_or_create_for_products(product1, product2)
    group = find_by(id: product1.product_group_id) if product1.product_group_id
    group ||= find_by(id: product2.product_group_id) if product2.product_group_id

    if group.nil? && product1.normalized_name.present?
      group = find_by(canonical_name: product1.normalized_name)
    end

    if group.nil? && product2.normalized_name.present?
      group = find_by(canonical_name: product2.normalized_name)
    end

    if group.nil?
      group = create(
        canonical_name: product1.normalized_name || product1.name,
        canonical_brand: product1.brand || product2.brand,
        alternative_names: [product1.name, product2.name].uniq
      )
    else
      alt_names = group.alternative_names || []
      alt_names << product1.name unless alt_names.include?(product1.name)
      alt_names << product2.name unless alt_names.include?(product2.name)
      group.update(alternative_names: alt_names.uniq)
    end

    product1.update(product_group: group) if product1.product_group_id.nil?
    product2.update(product_group: group) if product2.product_group_id.nil?

    group
  end

  def products_by_platform
    products.joins(:platform).group_by(&:platform)
  end

  def price_comparison
    wb_product = products.joins(:platform).find_by(platform: { slug: 'wb' })
    lamoda_product = products.joins(:platform).find_by(platform: { slug: 'lamoda' })

    {
      wb: wb_product&.current_price&.amount,
      lamoda: lamoda_product&.current_price&.amount,
      difference: if wb_product&.current_price && lamoda_product&.current_price
                    (wb_product.current_price.amount - lamoda_product.current_price.amount).abs
                  end,
      cheaper: if wb_product&.current_price && lamoda_product&.current_price
                 wb_product.current_price.amount < lamoda_product.current_price.amount ? 'wb' : 'lamoda'
               end
    }
  end
end