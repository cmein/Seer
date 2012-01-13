class FeedEntry < ActiveRecord::Base

  	belongs_to :feed
  	default_scope :order => 'published_at DESC'

	def self.init_from_feed(raw_feed)					
    	feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	init_entries(feed.entries, raw_feed.id)
  	end

	def self.add_from_feed(raw_feed, index)
		feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
    	add_entries(feed.entries, raw_feed.id, index)
  	end

  
  	private
  
  	def self.init_entries(entries, feed_id)				# initializes a new feed
    	feed = Feed.find(feed_id)						
		entries.each do |entry|							# for each entry....
			unless exists? :guid => entry.id				# check if the entry exists via its guid, if it doesn't exist...
				create!(										# create it!
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

	def self.add_entries(entries, feed_id, index)				# gets new entries
    	feed = Feed.find(feed_id)
		entries.each do |entry|							# for each entry....
			unless exists? :guid => entry.id				# check if the entry exists via its guid, if it doesn't exist...
				create!(										# create it!
					:name         => entry.title,
					:summary      => entry.summary,
					:content	  => entry.content,
					:url          => entry.url,
					:published_at => entry.published,
					:guid         => entry.id,
					:feed_id      => feed.id,
				)
				unless entry.published > (Time.now - 1.hr)
					#ANALYSIS!
					#analyze_entries(entry, feed)
				end
			end
		end
  	end

	def self.analyze_entries(entry, feed)												# individual entry analysis
		!entry.content.nil? ? entry_text = entry.content : entry_text = entry.summary	
		words = Sanitize.clean(entry_text).downcase.split(/[^a-zA-Z](?<!['\-])/) 			# the words are downcased, stripped of HTML, and split into an array
		words.each do |word|																# recording word frequencies for this iteration, into the freqs hash
			#next if blacklist.include?(word)
			if freqs[word][index].nil?															# if no slot exists for this feed
				(index - freqs[word].size).times do													# add slots of 0 up to this feed
					freqs[word] << 0
				end
				freqs[word] << 1																	# add a slot for this feed
			else
				freqs[word][index] += 1															# otherwise, increment
			end
		end
	end

end
