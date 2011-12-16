class FeedEntry < ActiveRecord::Base

  	belongs_to :feed
  	default_scope :limit => 10, :order => 'published_at DESC'

  	def self.add_from_feed(raw_feed)
    	feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	add_entries(feed.entries, raw_feed.id)
  	end
  
  	def self.update_from_feed(raw_feed)								#feed.rb's update_feed_entries method passes each feed as "raw_feed")
		feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	updated_feed = Feedzirra::Feed.update(feed)					#updates the passed raw_feed using its url attribute, saving it as "feed"
    	add_entries(updated_feed.new_entries, raw_feed.id) if updated_feed.updated?	#if feed has been updated, start the add_entries method, passing feed's new entries and raw_feed's id
  	end

	def self.update_from_feed_countinuously(raw_feed, delay_interval = 15.minutes)
    	feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
        add_entries(feed.entries, raw_feed.id)
        loop do
             sleep delay_interval
             updated_feed = Feedzirra::Feed.update(feed)
             add_entries(updated_feed.new_entries, raw_feed.id) if updated_feed.updated?
        end
	end
  

  	private
  
  	def self.add_entries(entries, feed_id)
    	feed = Feed.find(feed_id)						#take the raw_feed's id as feed_id and find that feed object
    	entries.each do |entry|							#for each entry....
      		unless exists? :guid => entry.id			#check if the entry exists via its guid, if it doesn't exist...
        		create!(								#create it!
          			:name         => entry.title,
          			:summary      => entry.summary,
					:content	  => entry.content,
          			:url          => entry.url,
          			:published_at => entry.published,
          			:guid         => entry.id,
          			:feed_id      => feed.id,
        		)
      		end
    	end
  	end

end
