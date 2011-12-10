class Category < ActiveRecord::Base
	has_many :feeds, :dependent => :destroy
	validates_presence_of :name, :iteration
end
