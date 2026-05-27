class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.string  :external_id
      t.string  :image_url
      t.string  :link, null: false
      t.decimal :rating, precision: 3, scale: 1, default: 0
      t.integer :reviews_qty, default: 0
      t.references :category, foreign_key: true
      t.references :platform, null: false, foreign_key: true
      t.timestamps
    end
    add_index :products, [:link, :platform_id], unique: true
  end
end
