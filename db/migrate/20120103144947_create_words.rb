class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.integer :alert
      t.float :pop_mean
      t.float :pop_sd
      t.text :history
      t.integer :category_id

      t.timestamps
    end
  end
end
