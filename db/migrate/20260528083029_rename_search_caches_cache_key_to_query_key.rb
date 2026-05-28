class RenameSearchCachesCacheKeyToQueryKey < ActiveRecord::Migration[7.1]
  def change
    rename_column :search_caches, :cache_key, :query_key
  end
end