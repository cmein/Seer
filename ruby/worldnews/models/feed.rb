class Feed < ActiveRecord::Base
	has_many :feed_entries, :dependent => :destroy
	attr_accessible :url	
end
