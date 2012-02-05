#!/usr/bin/env ruby

=begin

This is an offline, small-scale script for building and testing many of Seer's functions. It is run from the command line using:
	$ ruby main.rb [arguments]

=end

require "rubygems"
require "bundler/setup"
require "active_record"
require "sqlite3"
require 'yaml'
require 'feedzirra'
require "sanitize"

require 'fileutils' # <= only for copying files (making database backups)

dir = File.dirname(__FILE__)
Dir[dir+"/models/*.rb"].each {|file| require file }
require dir+"/core.rb"
require dir+"/db/migrate.rb"

# ENABLE FOR PROFILING
# require 'ruby-prof'

# displays feed entries in the console
def display_feed_entries(argv)
	if argv[1].nil?
		print "Include a feed ID\n"
	else
		feed = Feed.find_by_id(argv[1])
		if feed.nil?
			print "No feed by that id.\n"
		else
			p feed.url
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
			print "\n" + feed.feed_entries.size.to_s + " entries \n"
		end
	end
end

# def print_profiler_results
# 	# ENABLE FOR PROFILING
# 	result = RubyProf.stop
#   # Print a flat profile to text
#   printer = RubyProf::FlatPrinter.new(result)
#   printer.print(File.open('profiler/prof_flat.txt', 'w'), {:min_percent => 0, :print_file => true})
# 	printera = RubyProf::GraphPrinter.new(result)
#   printera.print(File.open('profiler/prof_graph.txt', 'w'), {:min_percent => 0, :print_file => true})
# 	printerb = RubyProf::CallTreePrinter.new(result)
# 	printerb.print(File.open('profiler/prof_tree.txt', 'w'), {:min_percent => 0, :print_file => true})
# 	printerc = RubyProf::GraphHtmlPrinter.new(result)
# 	printerc.print(File.open('profiler/prof_graph.html', 'w'), {:min_percent => 0, :print_file => true})
# end

db_connect # connect to database

case ARGV[0]
# Displays all feed urls
when "feeds"
	print Feed.all.size.to_s + " feeds\n"
	Feed.all.each { |feed| print [feed.id, feed.category.name, feed.url, feed.feed_entries.size].join(' => ') + " entries \n" }
# Displays all blacklisted words
when "blacklist"
	Blacklist.all.each { |word| print word.word + "\n" }
# Displays entries for a single feed
when "feed"
	display_feed_entries(ARGV)
# Category-specific commands
when "category"
	if ARGV[1].nil?
		print "Please include a category name\n"
	else
		category = Category.find_by_name(ARGV[1])
		if category.nil?
			print "This category doesn't seem to exist!\n"
		else
			ARGV[2].nil? ? limit_num = 100 : limit_num = ARGV[2]
			Word.where(:category_id => category.id).joins(:stats).order("stats.mean DESC").limit(limit_num).each { |word| puts word.name }
		end
	end
# Displays all categories with their feeds,
# number of feeds, and number of words
when "categories"
	Category.all.each do |category|
		print category.name + "\n"
		print category.feeds.size.to_s + " feeds, " + category.words.size.to_s + " unique words\n"
		print category.iteration.to_s + " iterations\n"
		category.feeds.each { |feed| print "\t" + feed.url + "\n" }
	end
# Looks for the given word,
# if it exists, returns its stat history
when "word"
	if ARGV[1].nil?
		print "Please include a word to search for.\n"
	else
		if Word.find_by_name(ARGV[1]).nil?
			print "Couldn't find this word.\n"
		else
			Category.all.each do |category|
				word = category.words.find_by_name(ARGV[1])
				next if word.nil?
				puts category.name
				word.stats.each do |stat|
					print stat.created_at.to_s + " => "
					print "Mean: " + stat.mean.to_s
					print " SD: " + stat.sd.to_s
					print " Presence: " + stat.presence.to_s + "\n"
				end
			end
		end
	end
# Updates all feeds
when "update"
	FileUtils.cp("db/database", "db/backups/"+Time.new.strftime("%Y%m%d%H%M%S"))
	update_feeds
# Spawns a new database if none exists,
# populates categories, feeds, and blacklist tables
when "spawn"
	spawn_tables	# generate tables if they don't exist
	spawn_feeds		# add categories & feeds to the respective tables
	spawn_blacklist	# add words to the blacklists table
	print "Database successfully created!\n"
# Updates categories, feeds, and blacklist tables
# with new records
when "migrate"
	spawn_feeds
	spawn_blacklist
# For testing from scratch
# Will DELETE the current database.
when "test"
	print "Beginning profiling test...\n" if ARGV[1] = "profile"
	RubyProf.start if ARGV[1] = "profile"
	FileUtils.cp("db/database", "db/backups/"+Time.new.strftime("%Y%m%d%H%M%S"))
	File.delete("db/database")
	spawn_tables
	spawn_feeds
	spawn_blacklist
	print "Database successfully created!\n"
	print "Updating feeds...\n"
	update_feeds
	print_profiler_results if ARGV[1] = "profile"
# Displays commands
else
	print "You may use the following arguments:\n"\
		"\tfeeds => returns all feeds with their id, category, url, and number of entries\n"\
		"\tblacklist => returns all blacklist words\n"\
		"\tfeed [ID] => returns all entries for a feed with the given [ID]\n"\
		"\tword [WORD] => returns the full stat history for the given [WORD]\n"\
		"\tcategories => returns all categories with feeds, number of feeds, and number of words\n"\
		"\tcategory [NAME] [RESULTS] => returns the most frequently appearing words for the [NAME] category,\n"\
		"\t\t\tlimited by [RESULTS] (optional, default returns 100 results)\n"\
		"\tupdate => updates all feeds, returns how many entries were added\n"\
		"\tspawn => will create the database & populate with categories, feeds, and blacklist items\n"\
		"\tmigrate => will update the database with newly added feeds or blacklist items\n"\
		"\ttest => will destroy the database, spawn a new one, and update the feeds\n"
end



 	
