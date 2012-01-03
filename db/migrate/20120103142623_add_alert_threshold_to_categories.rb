class AddAlertThresholdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :alert_threshold, :float
  end
end
