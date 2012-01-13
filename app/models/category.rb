class Category < ActiveRecord::Base
	has_many :feeds, :dependent => :destroy
	has_many :words, :dependent => :destroy
	validates_presence_of :name, :alert_threshold, :word_settings, :feed_settings, :map
	serialize :word_settings, Hash	# trial_length, blacklist_z
	serialize :feed_settings, Hash	# trial_length, min_post_rate, prune_threshold
	serialize :map, Hash			# type, subset_size, alpha
	serialize :word_stats, Hash
	before_create :init

	def init
		self.iteration ||= 0
		self.word_stats["pop_mean"] ||= 0
		self.word_stats["pop_sd"] ||= 0
	end

	def update_feeds	# run an iteration
		freqs = Hash.new { |hash,key| hash[key] = [] }		# will hold arrays of word frequencies
		n = self.feeds.size									# for now n = how many feeds are in the category
		self.feeds.each_with_index do |feed,index|			# FOR EACH FEED ANALYSIS
			feed.update_feed_entries(index)
		end
		freqs.each do |key,value|							# go over the iteration's word arrays
			unless exists? Word.find_by_name(key)						# checks if Word exists
				Word.new(:name => word, :category_id => self.id).save		# if not, create new Word
			end
			word = Word.find_by_name(key)
			(n.to_i - value.size).times {value << 0}			# adds n - value.size slots of 0 to the value array
			s_mean = value.inject(:+)/n
			s_var = 0											# technically, "variance" here is actually "variance*n"
			value.each { |item| s_var += (item - s_mean)**2 }
			s_sd = Math.sqrt(s_var/n)
			#word.update_attributes(:attribute => val), will also need to check the category's map params
		end
	end

end
