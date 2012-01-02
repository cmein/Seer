#!/usr/bin/env ruby

require 'rubygems'
require 'feedzirra'

feed_urls = Array.new

File.open("ruby/samplefeeds.txt", "r").each_line { |line| feed_urls << line }

puts feed_urls

entry_num = 0
feed_urls.each do |feed_url|
	feed = Feedzirra::Feed.fetch_and_parse(feed_url)
	feed.entries[0,100].each do |entry|
		entry.content.blank? ? entry_content = entry.summary : entry_content = entry.content
		File.new("ruby/testdata/"+entry_num.to_s+".txt", "w").write(entry_content)		#writes text file
		entry_num += 1
	end
end
