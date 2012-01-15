# connects to database
def db_connect
	dbconfig = YAML::load(File.open('database.yml')) # load database config
	ActiveRecord::Base.establish_connection(dbconfig) # "connect" to db
end

# generates tables if there are none
def spawn_tables
	# pseudo-migration / schema
	if !FeedEntry.table_exists?
		print "Creating feed entry table...\n"
		ActiveRecord::Base.connection.create_table(:feed_entries) do |t|
			t.column :name, :string
			t.column :content, :string
			t.column :url, :string
			t.column :guid, :string
			t.column :published_at, :datetime
			t.column :feed_id, :integer
		end
	end
	if !Feed.table_exists?
		print "Creating feed table...\n"
		ActiveRecord::Base.connection.create_table(:feeds) do |t|
			t.column :url, :string
		end
	end
	if !Blacklist.table_exists?
		print "Creating blacklist table...\n"
		ActiveRecord::Base.connection.create_table(:blacklists) do |t|
			t.column :word, :string
		end
	end
end

# creates or adds feeds from feeds.txt
def spawn_feeds
	File.open("feeds.txt", "r").each_line do |line|
		Feed.create(:url => line.strip) unless !Feed.find_by_url(line.strip).nil?
	end
end

# creates or adds blacklist items from blacklist.txt
def spawn_blacklist
	File.open("blacklist.txt", "r").each_line do |line|
		Blacklist.create(:word => line.strip) unless !Blacklist.find_by_word(line.strip).nil?
	end
end

# updates all feeds
def update_feeds
	# set up some variables for this iteration:
	freqs = Hash.new { |hash,key| hash[key] = [] }	# <= for holding word stats	for each feed
	word_counts = Array.new
	new_entries = 0																	# <= for keeping track of how many new entries there are
	connect_errors = 0 															# <= number of feeds that couldn't be connected to

	# start updating each feed
	Feed.find(:all).each_with_index do |raw_feed,index|
		word_counts[index] = 0
		feed = Feedzirra::Feed.fetch_and_parse(raw_feed.url)
		# if feedzirra couldn't reach the feed, count it as a connect error
		if feed==0
			connect_errors += 1
			next
		end
		# create new records for this feed's feed entries
		feed.entries.each do |entry|
			entry.content.blank? ? entry_content = entry.summary : entry_content = entry.content
			unless FeedEntry.exists? :guid => entry.id				# <= check if the entry exists via its guid, if it doesn't exist...
				FeedEntry.create!(															# <= create it!
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
	print "Couldn't connect to " + connect_errors.to_s + " feeds.\n"

	n = Feed.find(:all).size - connect_errors 	# <= calculate "n" for the sample
	process_words(freqs, n, word_counts)				# <= process the words
end

# displays feed entries in the console
def display_feed_entries(argv)
	if argv[1].nil?
		p "Include a feed ID"
	else
		p Feed.find_by_id(argv[1]).url
		FeedEntry.where(:feed_id => argv[1]).each do |entry|
			print entry.name+"\n\n"
			print entry.url+"\n"
			print Sanitize.clean(entry.content)+"\n"
			2.times do
				180.times {print "*" }
				print "\n"
			end
			print "\n"
			50.times { print "-" }		
		end
	end
end

private

# word farming
# 	index 				=> feed number, for this iteration
# 	entry_content => the entry text to be farmed
# 	freqs 				=> the word frequency hash for this iteration
# collects frequency of appearance for each word in this feed
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

# word processing
# 	freqs => the word frequency hash for this iteration
# 	connect_errors => number of feeds that couldn't be reached
# 	word_counts => array of total word counts per feed
# after all the feeds have been farmed,
# the frequency hash is converted from absolute frequencies to relative frequencies
def process_words(freqs, n, word_counts)
	# per word calculations
	stats = Hash.new
	freqs.each do |key,value|										# <= for each word...
		(n - value.size).times { value << 0 } 				# <= "fills up" word frequency array with 0s
		freqs[key] = value.each_with_index.map { |freq,index| freq.to_f/(word_counts[index]==0 ? 1 : word_counts[index])}		# <= converts each absolute frequency to a relative frequency
		stats[key] = crunch_stats(freqs[key], n)
	end
	puts freqs
	puts stats
end

# crunch stats (for this iteration)
# 	mean = average percent frequency of word in feeds
# 	sd = standard deviation of percent frequency of word in feeds
# 	feed_presence = percent of feeds this word was found in
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
	return [mean,sd,feed_presence]
end
