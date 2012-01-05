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
data_string = "Word,Total Frequency,Mean,SD,Z-Score,% of Total Words,Found in % Feeds\n"				#sets up columns for test dataCSV output
pop_mean = 0.0
pop_variance = 0.0


freqs = Hash.new { |hash,key| hash[key] = [] }
n = filearray.size.to_f															# n, simplified for this program
filearray.each_with_index do |item,index|										# this would be per feed entry
	words = Sanitize.clean(File.open(item) { |f| f.read }.downcase).split(/[^a-zA-Z](?<!['\-])/)			# the words are downcased, stripped of HTML, and split into an array
	words.each do |word|
		next if blacklist.include?(word)
		if freqs[word][index].nil?									# if that word (key) has no entry (value[iteration]) for that file (feed), append a new one,
			(index - freqs[word].size).times do
				freqs[word] << 0
			end
			freqs[word] << 1
		else
			freqs[word][index] += 1	 								# otherwise, increment
		end
	end
	unique_count_string << (index.to_s + "," + freqs.size.to_s + "\n")	# appends to unique word count
end

File.new("ruby/uniquewords.csv", "w").write(unique_count_string) # writes unique word count CSV output

total_words = 0		# keeps track of how many words total are found

stats = Hash.new(0)
freqs.sort_by { |x,y| y.inject(:+) }.reverse.each do |key,value|			# analysis of word samples
	found_feeds = 0		# keeps track of how many feeds this word was found in
	value.each { |item| item > 0 ? found_feeds += 1 : next }
	(n.to_i - value.size).times {value << 0}	#adds n - value.size entries of "0" to the value array
	sum = value.inject(:+)
	mean = sum/n
	pop_mean += mean
	variance = 0					# technically, "variance" here is actually "variance*n"
	value.each { |item| variance += (item - mean)**2 }
	sd = Math.sqrt(variance/n)
	stats[key] = [sum,mean,sd,((found_feeds.to_f/n)*100.0)]
	total_words += sum	
	#puts "\"#{key}\" found #{(mean*n).to_i} time(s) with a mean of #{mean} and a standard deviation of #{sd}"
end


#calculate population mean
pop_mean = pop_mean/freqs.size

#calculate population variance*n
stats.each do |key,value|
	pop_variance += (value[1] - pop_mean)**2	# again, actually "variance*n"
end

#calculate population standard deviation
pop_sd = Math.sqrt(pop_variance/freqs.size) 


#blacklist generation
blacklist_string = ""
blacklist_threshold = 5


stats.each do |key,value|
	zscore = (value[1] - pop_mean)/pop_sd
	percent_words = (value[0]/total_words.to_f)*100.0
	data_string << (key + "," + value[0].to_s + "," + value[1].to_s + "," + value[2].to_s + "," + zscore.to_s + "," + percent_words.to_s + "," + value[3].to_s + "\n")	#appends CSV output	
	zscore > blacklist_threshold ? blacklist_string << (key + "\n") : next	# a word's z-score, compared to the pop mean
end
File.new("ruby/blacklist.txt", "w").write(blacklist_string)

data_string << ("Population," + freqs.size.to_s + "," + pop_mean.to_s + "," + pop_sd.to_s + "," + "0" + "," + total_words.to_s + "," + "0" + "\n")
File.new("ruby/testdata.csv", "w").write(data_string)		# writes test data CSV output

puts freqs
