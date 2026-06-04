class SearchHistory < ApplicationRecord
  belongs_to :user

  validates :query, presence: true
  validates :normalized_query, presence: true
  validates :searched_at, presence: true

  scope :today, -> { where(searched_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :this_week, -> { where(searched_at: 7.days.ago..Time.current) }
  scope :this_month, -> { where(searched_at: 30.days.ago..Time.current) }

  after_create :cleanup_old_searches

  private

  def cleanup_old_searches
    user.search_histories.order(searched_at: :desc).offset(100).destroy_all
  end
end