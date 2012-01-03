class Category < ActiveRecord::Base
	has_many :feeds, :dependent => :destroy
	has_many :words, :dependent => :destroy
	validates_presence_of :name, :alert_threshold, :word_settings, :feed_settings, :map
	serialize :word_settings, Hash
	serialize :feed_settings, Hash
	serialize :map, Hash
	serialize :word_stats, Hash
	before_create :init

	def init
		self.iteration ||= 0
	end

end
