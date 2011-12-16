class Feed < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :name, :category_id
	validates :url, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }	
    attr_accessible :name, :url
	has_many :feed_entries, :dependent => :destroy
	after_create :create_feed_entries


	def self.update_feed_entries
    	feeds = Feed.all
    	feeds.each do |feed|
      		FeedEntry.update_from_feed(feed) #calls FeedEntry's (feed_entry.rb) update_from_feed method for each feed, passing the feed to the method
    	end
  	end

	def self.add_feed_entries
		feeds = Feed.all
		feeds.each do |feed|
			FeedEntry.add_from_feed(feed)
		end
	end

	def update_single_feed_entries
		FeedEntry.update_from_feed(self)
	end
  
  	def create_feed_entries
    	FeedEntry.add_from_feed(self)
  	end

  	private	
  
  	def delete_feed_entries
    	self.feed_entries.each do |entry|
	    	entry.destroy
	  	end
  	end

end
