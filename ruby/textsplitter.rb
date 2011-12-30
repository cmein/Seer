#!/usr/bin/env ruby

require 'set'

filearray = Array[ "ruby/text.txt", "ruby/text2.txt", "ruby/text3.txt" ]
blacklist = Set.new([ "", "is", "the", "a", "s" ])

freqs = Hash.new { |hash,key| hash[key] = [] }
n = filearray.size.to_f															# n, simplified for this program
filearray.each_with_index do |item,index|										# this would be per feed entry
	words = File.open(item) { |f| f.read }.downcase.split(/[^a-zA-Z]/)			# the words are downcased and split into an array
	words.each do |word|
		next if blacklist.include?(word)
		freqs[word][index].nil? ? freqs[word] << 1 : freqs[word][index] += 1	# if that word has no entry for that file (i.e. feed), append a new one, otherwise, increment
	end
end
puts freqs

stats = Hash.new(0)
freqs.each do |key,value|			# analysis of word samples
	sum = value.inject(:+)
	mean = sum/n
	variance = 0					# technically, "variance" here is actually "variance*n"
	value.each { |item| variance += (item - mean)**2 }
	sd = Math.sqrt(variance/n)
	stats[key] = [sum,mean,sd]
	puts "\"#{key}\" found #{(mean*n).to_i} time(s) with a mean of #{mean} and a standard deviation of #{sd}"
end
puts stats

#note: need to get a better regex to so contractions aren't split!
