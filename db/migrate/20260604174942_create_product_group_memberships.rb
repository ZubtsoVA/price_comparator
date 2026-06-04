class CreateProductGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :product_group_memberships do |t|
      t.references :product, null: false, foreign_key: true
      t.references :product_group, null: false, foreign_key: true
      t.string :variant_type
      t.string :variant_value

      t.timestamps
    end

    add_index :product_group_memberships, [:product_id, :product_group_id],
              unique: true, name: 'idx_membership_unique'
    add_index :product_group_memberships, [:product_group_id, :variant_type, :variant_value],
              name: 'idx_group_variants'
  end
end