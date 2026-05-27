class CreatePrices < ActiveRecord::Migration[7.1]
  def change
    create_table :prices do |t|
      t.references :product, null: false, foreign_key: true
      t.references :platform, null: false, foreign_key: true
      t.integer :amount, null: false
      t.datetime :recorded_at, null: false
    end
    add_index :prices, [:product_id, :recorded_at]
    add_index :prices, [:product_id, :platform_id, :recorded_at]
  end
end
