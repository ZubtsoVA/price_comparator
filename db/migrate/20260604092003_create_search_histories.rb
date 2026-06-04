class CreateSearchHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :search_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :query, null: false
      t.string :normalized_query, null: false
      t.integer :results_count, default: 0
      t.json :filters_applied
      t.string :ip_address
      t.string :user_agent
      t.datetime :searched_at, null: false

      t.timestamps
    end
    add_index :search_histories, [:user_id, :searched_at]
    add_index :search_histories, [:user_id, :normalized_query]
    add_index :search_histories, :searched_at
  end
end
