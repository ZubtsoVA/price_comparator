class SearchCache < ApplicationRecord
  serialize :results, coder: JSON
  validates :cache_key, presence: true, uniqueness: true

  scope :alive, -> { where("expires_at > ?", Time.current) }

  def self.fetch(key)
    record = alive.find_by(cache_key: key)
    record&.results
  end

  def self.store(key, data, ttl: 2.hours)
    upsert(
      { cache_key: key, results: data, expires_at: ttl.from_now },
      unique_by: :cache_key
    )
  end

  def self.clear_expired!
    where("expires_at <= ?", Time.current).delete_all
  end
end
