class CreateUserFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :user_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.text :notes
      t.integer :priority, default: 0
      t.boolean :notify_on_price_drop, default: false
      t.integer :target_price

      t.timestamps
    end
    add_index :user_favorites, [:user_id, :product_id], unique: true
  end
end
