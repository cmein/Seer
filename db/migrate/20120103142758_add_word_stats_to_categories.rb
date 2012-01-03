class AddWordStatsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :word_stats, :text
  end
end
