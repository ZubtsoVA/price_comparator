class Price < ApplicationRecord
  belongs_to :product
  belongs_to :platform

  validates :amount, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_platform, ->(platform) { where(platform: platform) }
  scope :history, -> { order(recorded_at: :asc) }
end
