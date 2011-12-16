class RemoveFormatFromFeeds < ActiveRecord::Migration
  def up
    remove_column :feeds, :format
  end

  def down
    add_column :feeds, :format, :integer
  end
end
