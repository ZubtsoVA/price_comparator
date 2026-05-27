class CreatePlatforms < ActiveRecord::Migration[7.1]
  def change
    create_table :platforms do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :base_url, null: false
      t.timestamps
    end
    add_index :platforms, :slug, unique: true
  end
end
