class RemoveProductGroupIdFromProducts < ActiveRecord::Migration[8.1]
  def change

    if foreign_key_exists?(:products, :product_groups)
      remove_foreign_key :products, :product_groups
    end


    if index_exists?(:products, :product_group_id)
      remove_index :products, :product_group_id
    end

    if column_exists?(:products, :product_group_id)
      remove_column :products, :product_group_id
    end
  end
end