class CreateProductGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :product_groups do |t|
      t.string :canonical_name, null: false
      t.string :canonical_brand
      t.json :alternative_names

      t.timestamps
    end
    add_index :product_groups, :canonical_name
  end
end
