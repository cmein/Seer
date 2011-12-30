#!/usr/bin/env ruby

freqs = Hash.new { |hash,key| hash[key] = [] }
filearray = Array[ "ruby/text.txt", "ruby/text2.txt", "ruby/text3.txt" ]
filearray.each_with_index do |item,index|
	words = File.open(item) { |f| f.read }.downcase.split(/[^a-zA-Z]/)
	words.each { |word| freqs[word][index].nil? ? freqs[word] << 1 : freqs[word][index] += 1 }
end
puts freqs
