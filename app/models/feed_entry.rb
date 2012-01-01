class FeedEntry < ActiveRecord::Base

  	belongs_to :feed
  	default_scope :order => 'published_at DESC'

	def self.init_from_feed(raw_feed)					
    	feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	init_entries(feed.entries, raw_feed.id)
  	end

	def self.add_from_feed(raw_feed)
		feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	add_entries(feed.entries, raw_feed.id)
  	end

  
  	private
  
  	def self.init_entries(entries, feed_id)
    	feed = Feed.find(feed_id)						
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

	def self.add_entries(entries, feed_id)
    	feed = Feed.find(feed_id)						
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
				#here do the analysis function. might still need to check if entry was created within current time - 1 hour
			end
		end
  	end

end
