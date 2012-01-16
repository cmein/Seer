class Category < ActiveRecord::Base
	has_many :feeds, :dependent => :destroy
	has_many :words, :dependent => :destroy
	has_many :stats, { :as => :statable, :dependent => :destroy }
	attr_accessible :name
	serialize :word_settings, Hash		# <= trial_length, blacklist_z, :alert_threshold
	serialize :feed_settings, Hash		# <= trial_length, min_post_rate, prune_threshold
	serialize :map, Hash							# <= type, subset_size, alpha
	before_create :init

	def init
		self.iteration ||= 0
	end

end
