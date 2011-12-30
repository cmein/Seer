#!/usr/bin/env ruby

freqs = Hash.new(0)
filearray = Array[ "ruby/text.txt", "ruby/text2.txt", "ruby/text3.txt" ]
filearray.each do |item|
	words = File.open(item) { |f| f.read }.downcase.split(/[^a-zA-Z]/)
	words.each { |word| freqs[word] += 1 }
end
puts freqs
