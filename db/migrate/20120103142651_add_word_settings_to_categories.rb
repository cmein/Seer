class AddWordSettingsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :word_settings, :text
  end
end
