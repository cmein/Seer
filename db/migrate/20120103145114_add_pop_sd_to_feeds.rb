class AddPopSdToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :pop_sd, :float
  end
end
