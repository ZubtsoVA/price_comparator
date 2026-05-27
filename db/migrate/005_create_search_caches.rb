class CreateSearchCaches < ActiveRecord::Migration[7.1]
  def change
    create_table :search_caches do |t|
      t.string :cache_key, null: false
      t.json :results, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :search_caches, :cache_key, unique: true
    add_index :search_caches, :expires_at
  end
end
