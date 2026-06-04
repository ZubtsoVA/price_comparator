class AddFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:products, :product_group_id)
      add_reference :products, :product_group, foreign_key: true, index: true
    end
    unless column_exists?(:products, :normalized_name)
      add_column :products, :normalized_name, :string
    end
    unless column_exists?(:products, :brand)
      add_column :products, :brand, :string
    end

    unless index_exists?(:products, :normalized_name)
      add_index :products, :normalized_name
    end
    unless index_exists?(:products, :brand)
      add_index :products, :brand
    end
  end
end
