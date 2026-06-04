class AddTypeAndSlugToProductGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :product_groups, :group_type, :string, null: false, default: 'brand' unless column_exists?(:product_groups, :group_type)
    add_column :product_groups, :slug, :string unless column_exists?(:product_groups, :slug)
    add_column :product_groups, :keywords, :json unless column_exists?(:product_groups, :keywords)

    unless index_exists?(:product_groups, :slug)
      add_index :product_groups, :slug, unique: true
    end

    unless index_exists?(:product_groups, [:group_type, :slug])
      add_index :product_groups, [:group_type, :slug], unique: true, name: 'idx_groups_on_type_and_slug'
    end
  end
end