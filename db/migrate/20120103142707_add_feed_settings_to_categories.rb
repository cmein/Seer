class AddFeedSettingsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :feed_settings, :text
  end
end
