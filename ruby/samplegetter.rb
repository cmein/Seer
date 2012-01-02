#!/usr/bin/env ruby

require 'rubygems'
require 'feedzirra'

feed_urls = Array[ "http://rss.cnn.com/rss/edition_prismblog.rss", "http://rss.cnn.com/rss/edition_business360.rss", "http://www.thebeijinger.com/blog/feed", "http://fulltextrssfeed.com/rss.cnn.com/rss/cnn_topstories.rss", "http://fulltextrssfeed.com/feeds.abcnews.com/abcnews/topstories" ]

entry_num = 0
feed_urls.each do |feed_url|
	feed = Feedzirra::Feed.fetch_and_parse(feed_url)
	feed.entries[0,100].each do |entry|
		entry.content.blank? ? entry_content = entry.summary : entry_content = entry.content
		File.new("ruby/testdata/"+entry_num.to_s+".txt", "w").write(entry_content)		#writes text file
		entry_num += 1
	end
end
