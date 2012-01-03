class Feed < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :name, :category_id
	validates :url, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }	
    attr_accessible :name, :url, :alert, :pop_mean, :sample_mean, :history
	has_many :feed_entries, :dependent => :destroy
	before_create :init, :init_feed_entries
	serialize :history, Array

	def init
		self.alert ||= 0
		self.pop_mean ||= 0.0
		self.pop_sd ||= 0.0
		self.sample_mean ||= 0.0
	end

	def self.add_all_feed_entries
		feeds = Feed.all
		feeds.each do |feed|
			FeedEntry.add_from_feed(feed)
		end
	end

	def add_single_feed_entries
		FeedEntry.add_from_feed(self)
	end
  
  	def init_feed_entries
    	FeedEntry.init_from_feed(self)
  	end

  	private	
  
  	def delete_feed_entries
    	self.feed_entries.each do |entry|
	    	entry.destroy
	  	end
  	end

end
