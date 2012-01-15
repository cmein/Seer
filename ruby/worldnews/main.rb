#!/usr/bin/env ruby

=begin

This is an offline, small-scale script for building and testing many of Seer's functions. It is run from the command line using:
	$ ruby main.rb [arguments]

=end

require "rubygems"
require "active_record"
require "sqlite3"
require 'yaml'
require 'feedzirra'
require "sanitize"

dir = File.dirname(__FILE__)
Dir[dir+"/models/*.rb"].each {|file| require file }
require dir+"/methods.rb"

db_connect # connect to database

case ARGV[0]
when "feeds"	# <= displays all feed urls
	print Feed.find(:all).size.to_s + " feeds\n"
	Feed.find(:all).each { |feed| print [feed.id, feed.url, feed.feed_entries.size].join(' => ') + " entries \n" }
when "blacklist"	# <= displays all blacklisted words
	Blacklist.find(:all).each { |word| print word.word + "\n" }
when "feed"	# <= displays entries for a single feed
	display_feed_entries(ARGV)
when "update"
	update_feeds	# update feeds
when "spawn"
	spawn_tables	# generate tables if they don't exist
	spawn_feeds		# add feeds to the feeds table
	spawn_blacklist	# add words to the blacklists table
	print "Database successfully created!\n"
when "test"	# <= for testing from scratch. will delete the current database.
	File.delete("worldnews")
	spawn_tables
	spawn_feeds
	spawn_blacklist
	print "Database successfully created!\n"
	print "Updating feeds...\n"
	update_feeds
else	# <= displays commands
	print "You may use the following arguments:\n"\
		"\tfeeds => returns all feed urls and their id\n"\
		"\tblacklist => returns all blacklist words\n"\
		"\tfeed [ID] => returns all entries for a feed with the given [ID]\n"\
		"\tupdate => updates all feeds, returns how many entries were added\n"\
		"\tspawn => will update the database with new feeds or blacklisted words\n"
end

