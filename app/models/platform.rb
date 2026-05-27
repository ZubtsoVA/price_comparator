class Platform < ApplicationRecord
  has_many :prices
  has_many :products

  validates :name, :slug, :base_url, presence: true
  validates :slug, uniqueness: true
end
