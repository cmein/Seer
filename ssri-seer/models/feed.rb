class Feed < ActiveRecord::Base
	belongs_to :category
	has_many :feed_entries, :dependent => :destroy
	has_many :stats, { :as => :statable, :dependent => :destroy }
	attr_accessible :url, :alert, :category_id
	before_create :init

	def init
		self.alert ||= 0
	end

end
