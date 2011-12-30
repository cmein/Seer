#!/usr/bin/env ruby

freqs = Hash.new { |hash,key| hash[key] = [] }
filearray = Array[ "ruby/text.txt", "ruby/text2.txt", "ruby/text3.txt" ]
n = filearray.size.to_f
filearray.each_with_index do |item,index|
	words = File.open(item) { |f| f.read }.downcase.split(/[^a-zA-Z]/)
	words.each { |word| freqs[word][index].nil? ? freqs[word] << 1 : freqs[word][index] += 1 }
end
puts freqs

stats = Hash.new(0)
freqs.each do |key,value|
	mean = value.inject(:+)/n
	variance = 0
	value.each { |item| variance += (item - mean)**2 }
	sd = Math.sqrt(variance/n)
	stats[key] = [mean,sd]
	puts "\"#{key}\" found #{(mean*n).to_i} time(s) with a mean of #{mean} and a standard deviation of #{sd}"
end
puts stats
