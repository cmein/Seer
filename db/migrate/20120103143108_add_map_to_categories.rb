class AddMapToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :map, :text
  end
end
