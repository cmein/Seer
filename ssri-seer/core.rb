# updates all feeds
def update_feeds
	log_string = "" # *TEST*
	Category.all.each do |category|
		@category = category
		@category_word_count = 0												# <= for keeping track of unique words found during this iteration # *TEST*
		print "Updating " + @category.name + "...\n"		# *TEST*
		# set up some variables for this iteration:
		freqs = Hash.new { |hash,key| hash[key] = [] }	# <= for holding word stats	for each feed
		word_counts = Array.new													# <= for keeping track of how many words there are per feed
		new_entries = 0																	# <= for keeping track of how many new entries there are
		connect_errors = 0 															# <= number of feeds that couldn't be connected to	# *TEST*
		connect_error_feeds = []												# <= holds the feeds that couldn't be connected to	# *TEST* HOWEVER may be adapted to feed pruning

		# start updating each feed
		@category.feeds.all.each_with_index do |raw_feed,index|
			word_counts[index] = 0
			print "Fetching " + raw_feed.url + "\n"			# *TEST*
			feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
			# if feedzirra couldn't reach the feed, count it as a connect error
			if feed==0 or feed.nil?
				connect_errors += 1										# *TEST*
				connect_error_feeds << raw_feed.url		# *TEST* => HOWEVER this will later be adapted to feed pruning
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
		# print some info *TEST*
		if new_entries > 0
			print "Update complete. There were " + new_entries.to_s + " new entries.\n"
		else
			print "Update complete. No new entries found.\n"
		end
		if connect_errors > 0
			print "Couldn't connect to " + connect_errors.to_s + " feeds:\n"
			puts connect_error_feeds
		end
		# END *TEST*

		if new_entries > 0
			print "Processing words...\n"			# *TEST*	
			n = @category.feeds.all.size - connect_errors 	# <= calculate "n" for the sample		
			process_words(freqs, n, word_counts)									# <= process the words
			@category.update_attributes(:iteration => @category.iteration + 1)
			print "This category has gone through " + @category.iteration.to_s + " iterations.\n" # *TEST*

			# *TEST*
			# log printing:
			log_string << @category.name + "\nHad " + connect_errors.to_s + " connect errors.\n"
			connect_error_feeds.each { |feed| log_string << ("\t" + feed + "\n") }
			log_string << ("Found " + @category_word_count.to_s + " new unique words in " + new_entries.to_s + " new entries.\n")
			log_string << ("This was the category's " + @category.iteration.to_s + " iteration.\n\n")
		end
	end
	print "Update complete!\n"				# *TEST*
	File.new("logs/"+Time.new.strftime("%Y%m%d%H%M%S")+".txt", "w").write(log_string)			#	*TEST*
end

private

# Word Farming
# 	index 				=> feed number, for this iteration
# 	entry_content => the entry text to be farmed
# 	freqs 				=> the word frequency hash for this iteration
# 	word_counts		=> total number of words in this feed's update
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
# 	n => number of feeds that were parsed
# 	word_counts => array of total word counts per feed
# After all the feeds have been farmed,
# the frequency hash is converted from
# absolute frequencies to relative frequencies
def process_words(freqs, n, word_counts)
	@category_means = []													# <= for holding mean relative frequency for each word found during this iteration
	@category_presences = []											# <= for holding feed presences for each word found during this iteration
	# per word calculations
	stats = Hash.new
	freqs.each do |key,value|										# <= for each word...
		(n - value.size).times { value << 0 } 				# <= "fills up" word frequency array with 0s
		freqs[key] = value.each_with_index.map { |freq,index| freq.to_f/(word_counts[index]==0 ? 1 : word_counts[index])}		# <= converts each absolute frequency to a relative frequency
		stats[key] = crunch_word_stats(freqs[key], n)
		update_word_stats(key, stats[key])
	end
	update_category_stats(freqs.size)
end

# Crunch Word Stats
# 	value => array of relative frequencies for the word
# 	n => number of feeds that were parsed
# Calculates some statistics for a word (mean, standard deviation, feed presence)	
# Returns an array of:
# 	mean = average percent frequency of word in feeds
# 	sd = standard deviation of percent frequency of word in feeds
# 	feed_presence = percent of feeds this word was found in
def crunch_word_stats(value, n)
	mean = value.inject(:+)/n.to_f
	@category_means << mean	# <= add this word's mean to the category_means array
	variance = 0	# <= technically, this is actually variance*n
	feed_presence = 0	
	value.each do |item|
		variance += (item - mean)**2
		feed_presence += 1 if item > 0
	end
	feed_presence = feed_presence/n.to_f
	@category_presences << feed_presence # <= add this word's feed presence to the category_presence array
	sd = Math.sqrt(variance/n)
	return [mean, sd, feed_presence]
end

# Update Word Stats
# 	key => the word, used as a key for the stats hash
# 	stats => the array of that word's statistics for this iteration
# 		=> [mean, sd, feed_presence]
# Creates stat record for a word record.
# If no word record exists, one is created.
def update_word_stats(key, stats)
	if @category.words.find_by_name(key).nil?	# <= create a new word if it doesn't exist
		@category.words.create(:name => key)
		@category_word_count += 1			# *TEST*
	end
	word = @category.words.find_by_name(key)
	word.stats.create(:mean => stats[0], :sd => stats[1], :presence => stats[2])
end

# Update Category Stats
# 	n => the size of the freqs hash
# Creates a new stat record for the category.
def update_category_stats(n)
	category_mean = @category_means.inject(:+)/n
	category_presence = @category_presences.inject(:+)/n
	category_variance = 0	# <= technically, this is variance*n
	@category_means.each { |item| category_variance += (item - category_mean)**2 }
	category_sd = Math.sqrt(category_variance/n)
	# For this category, this iteration:
	# 	mean = mean relative frequency for words,
	# 	sd = standard deviation from the mean,
	# 	presence = mean presence for words,
	# 	pop = unique words found
	@category.stats.create(:mean => category_mean, :sd => category_sd, :presence => category_presence, :pop => @category_word_count)
end

