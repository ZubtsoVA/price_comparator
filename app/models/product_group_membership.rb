class ProductGroupMembership < ApplicationRecord
  belongs_to :product
  belongs_to :product_group

  validates :product_id, uniqueness: { scope: :product_group_id }

  scope :by_variant, ->(type, value) { where(variant_type: type, variant_value: value) }
end