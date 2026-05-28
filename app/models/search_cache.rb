class SearchCache < ApplicationRecord
  validates :query_key, presence: true, uniqueness: true

  scope :alive, -> { where("expires_at > ?", Time.current) }

  def self.fetch(key)
    record = alive.find_by(query_key: key)
    record&.results
  end

  def self.store(key, data, ttl: 2.hours)
    record = find_or_initialize_by(query_key: key)
    record.results    = data
    record.expires_at = ttl.from_now
    record.save!
  end

  def self.clear_expired!
    where("expires_at <= ?", Time.current).delete_all
  end
end
