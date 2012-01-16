# updates all feeds
def update_feeds
	Category.find(:all).each do |category|
		@category = category
		print "Updating " + @category.name + "...\n"
		# set up some variables for this iteration:
		freqs = Hash.new { |hash,key| hash[key] = [] }	# <= for holding word stats	for each feed
		word_counts = Array.new
		new_entries = 0																	# <= for keeping track of how many new entries there are
		connect_errors = 0 															# <= number of feeds that couldn't be connected to
		connect_error_feeds = []												# <= holds the feeds that couldn't be connected to

		# start updating each feed
		@category.feeds.find(:all).each_with_index do |raw_feed,index|
			word_counts[index] = 0
			feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
			# if feedzirra couldn't reach the feed, count it as a connect error
			if feed==0
				connect_errors += 1
				connect_error_feeds << raw_feed.url
				next
			end
			# create new records for this feed's feed entries
			feed.entries.each do |entry|
				entry.content.blank? ? entry_content = entry.summary : entry_content = entry.content
				unless raw_feed.feed_entries.exists? :guid => entry.id				# <= check if the entry exists via its guid, if it doesn't exist...
					raw_feed.feed_entries.create!(															# <= create it!
						:name         => entry.title,
						:content	 	  => entry_content,
						:url          => entry.url,
						:published_at => entry.published,
						:guid         => entry.id,
						:feed_id      => raw_feed.id,
					)
					new_entries += 1 									# <= increment new entry count
					farm_words(index, entry_content, freqs, word_counts) 	# <= "farm" the words from this entry to the freqs hash
				end
			end
		end
		# print some info
		if new_entries > 0
			print "Update complete. There were " + new_entries.to_s + " new entries.\n"
		else
			print "Update complete. No new entries found.\n"
		end
		if connect_errors > 0
			print "Couldn't connect to " + connect_errors.to_s + " feeds:\n"
			puts connect_error_feeds
		end

		n = @category.feeds.find(:all).size - connect_errors 	# <= calculate "n" for the sample
		print "Processing words...\n"
		process_words(freqs, n, word_counts) if new_entries > 0			# <= process the words
	end
	print "Update complete!\n"
end

private

# Word Farming
# 	index 				=> feed number, for this iteration
# 	entry_content => the entry text to be farmed
# 	freqs 				=> the word frequency hash for this iteration
# Collects frequency of appearance for each word in this feed
def farm_words(index, entry_content, freqs, word_counts)
	words = Sanitize.clean(entry_content.downcase).split(/[^a-zA-Z](?<!['\-])/) 	# <= clean up & split the words
	words.each do |word|
		next if !Blacklist.find_by_word(word).nil?													# <= check against blacklist
		if freqs[word][index].nil?																							# <= if word doesn't exist yet
			(index - freqs[word].size).times { freqs[word] << 0	}									# <= add a zero for each entry until this one
			freqs[word] << 1
		else
			freqs[word][index] += 1																								# <= otherwise, just increment the count
		end
	end
	word_counts[index] += words.size
end

# Word Processing
# 	freqs => the word frequency hash for this iteration
# 	connect_errors => number of feeds that couldn't be reached
# 	word_counts => array of total word counts per feed
# After all the feeds have been farmed,
# the frequency hash is converted from
# absolute frequencies to relative frequencies
def process_words(freqs, n, word_counts)
	# per word calculations
	stats = Hash.new
	freqs.each do |key,value|										# <= for each word...
		(n - value.size).times { value << 0 } 				# <= "fills up" word frequency array with 0s
		freqs[key] = value.each_with_index.map { |freq,index| freq.to_f/(word_counts[index]==0 ? 1 : word_counts[index])}		# <= converts each absolute frequency to a relative frequency
		stats[key] = crunch_stats(freqs[key], n)
		update_stats(key, stats[key])
	end
	#puts freqs
	#puts stats
	Word.find(:all).each do |word|
		puts word.name
		word.stats.find(:all).each { |stat| puts stat.mean.to_s + ", " + stat.sd.to_s + ", " + stat.presence.to_s  }
	end
end

# Crunch Stats
# 	mean = average percent frequency of word in feeds
# 	sd = standard deviation of percent frequency of word in feeds
# 	feed_presence = percent of feeds this word was found in
# Calculates some statistics for a word (mean, standard deviation, feed presence)

def crunch_stats(value, n)
	mean = value.inject(:+)/n.to_f
	variance = 0	# <= technically, this is actually variance*n
	feed_presence = 0	
	value.each do |item|
		variance += (item - mean)**2
		feed_presence += 1 if item > 0
	end
	feed_presence = feed_presence/n.to_f
	sd = Math.sqrt(variance/n)
	return [mean, sd, feed_presence]
end

# Update Stats
# 	key = the word, used as a key for the stats hash
# 	stats = the array of that word's statistics for this iteration
# 		=> [mean, sd, feed_presence]
# Updates the statistics for a word record.
# If no word record exists, one is created.
def update_stats(key, stats)
	@category.words.create(:name => key) if @category.words.find_by_name(key).nil?	# <= create a new word if it doesn't exist
	word = @category.words.find_by_name(key)
	word.stats.create(:mean => stats[0], :sd => stats[1], :presence => stats[2])
end
