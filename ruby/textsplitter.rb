#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'sanitize'

filearray = Array.new
(Dir.entries("ruby/testdata").size - 3).times do |i|
	filearray << ("ruby/testdata/"+i.to_s+".txt")
end

blacklist = Set.new([ "" ])

unique_count_string = "Entries,Unique Words\n"									# will look at relationship b/w number of entries analyzed & number of unique words found

freqs = Hash.new { |hash,key| hash[key] = [] }
n = filearray.size.to_f															# n, simplified for this program
filearray.each_with_index do |item,index|										# this would be per feed entry
	words = Sanitize.clean(File.open(item) { |f| f.read }.downcase).split(/[^a-zA-Z](?<!['\-])/)			# the words are downcased, stripped of HTML, and split into an array
	words.each do |word|
		next if blacklist.include?(word)
		freqs[word][index].nil? ? freqs[word] << 1 : freqs[word][index] += 1	# if that word (key) has no entry (value[iteration]) for that file (feed), append a new one, otherwise, increment
	end
	unique_count_string << (index.to_s + "," + freqs.size.to_s + "\n")	# appends to unique word count
end

File.new("ruby/uniquewords.csv", "w").write(unique_count_string) # writes unique word count CSV output

data_string = "Word,Total Frequency,Mean,SD\n"				#sets up columns for CSV output
pop_mean = 0.0
pop_variance = 0.0


stats = Hash.new(0)
freqs.sort_by { |x,y| y.inject(:+) }.reverse.each do |key,value|			# analysis of word samples
	(n.to_i - value.size).times {value << 0}	#adds n - value.size entries of "0" to the value array
	sum = value.inject(:+)
	mean = sum/n
	pop_mean += mean
	variance = 0					# technically, "variance" here is actually "variance*n"
	value.each { |item| variance += (item - mean)**2 }
	sd = Math.sqrt(variance/n)
	stats[key] = [sum,mean,sd]
	puts "\"#{key}\" found #{(mean*n).to_i} time(s) with a mean of #{mean} and a standard deviation of #{sd}"
	data_string << (key + "," + sum.to_s + "," + mean.to_s + "," + sd.to_s + "\n")	#appends CSV output
end


#calculate population mean
pop_mean = pop_mean/freqs.size

#calculate population variance*n
stats.each do |key,value|
	pop_variance += (value[1] - pop_mean)**2	# again, actually "variance*n"
end

#calculate population standard deviation
pop_sd = Math.sqrt(pop_variance/freqs.size) 

data_string << ("Population," + freqs.size.to_s + "," + pop_mean.to_s + "," + pop_sd.to_s + "\n")

File.new("ruby/testdata.csv", "w").write(data_string)		# writes test data CSV output

blacklist_string = ""
blacklist_threshold = 5
stats.each do |key,value|
	(value[1] - pop_mean)/pop_sd > blacklist_threshold ? blacklist_string << (key + "\n") : next	# a word's z-score, compared to the pop mean
end
File.new("ruby/blacklist.txt", "w").write(blacklist_string)
