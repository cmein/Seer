#Seer Readme

Notes: Syntatically and semantically unbiased; core features will be based purely on statistics. Language-specific functions will be contained to modules. 
  

###Current Priority
- Figure out how to collect a large sample of feed entries (n=5000). Currently most feeds only show latest 10 entries, how to get more entries?

  

###Usage:
Rails environment is basically setup but all the "real" code is currently in /ruby for testing.

####samplegetter.rb
run from the command line with:
    <pre>$ ruby ./ruby/samplegetter.rb</pre>

This pulls from an array of feeds from ruby/samplefeeds.txt and saves their entries' contents as .txt files to ruby/testdata

####textsplitter.rb
run in the command line with:
    <pre>$ ruby ./ruby/textsplitter.rb</pre>

Takes the .txt files created by samplegetter.rb (ruby/testdata/\*.txt) and analyzes them. Prints each unique word and its frequency, mean, and standard deviation, and saves all this output to ruby/testdata.csv. Estimates which words should belong on the blacklist by z-score and outputs the list to ruby/blacklist.txt.

---

###Unresolved Issues
- Alternate spellings & misspellings
- Acronyms
- Special characters
- Plurals
- Conjugations  
  

###Future Features
- Get full posts from feeds that only show summaries (like: http://fulltextrssfeed.com/ & http://www.wizardrss.com/)
  


###Development Roadmap
- Feedzirra error handling (i.e. can't reach server)
- Proper merging of sample means into population moving average
- Ensure feed entries have good content length (i.e. how to detect that it's the full post and not just a summary/one-liner?)
- Word & feed trial periods. Start with some training data or just a training period?
- Figure out/test automated blacklisting
- Implement code into rails
- Finish basic feed parsing & analysis functions, test
- Determine ideal p threshold. If this is even the best approach?
- Automated feed pruning
- Develop "conceptual maps"/"relational maps" for words using Wikipedia database, and weighting based on those maps
- Incorporating presence of HTML tags in weighting word importance?
- Feed weighting according to significant correlation with "trending" words?
- Automated article recommendations based on trending words
- Automated feed discovery
- Phrase detection with markov chains (or a better approach)
  


###Considerations
- It may be worthwhile to NOT include a spellchecker. Misspellings are likely to be statistically insignifcant, and would likely mean that some words are mistakenly flagged as misspelled.
- For plurals, use Ruby's built-in pluralization engine. It is not perfect but may suffice
- For conjugations, consider using: https://github.com/ged/linguistics
- So far, the biggest contributor to program time is downloading all the entries. With enough feeds to check, it may not be feasible to check multiple categories each hour.

---

##Classes
<pre>
Word => { 
	belongs_to => category,
	name => string,
	history => serialized text => float array,
	pop_mean => float,
	pop_sd => float,
	alert => int,
	category_id => int,
	hour_count => int array (TEMPORARY, NOT AN ATTRIBUTE)
}
</pre>

<pre>
Category => {
	has_many => [feeds, words],
	name => string,
	iterations => integer,
	alert_threshold => float,
	word_settings => serialized text => hash [word trial length, blacklist z-score],
	feed_settings => serialized text => hash [feed trial length, minimum post rate, prune threshold],
	word_stats => serialized text => hash [pop mean, pop standard deviation],
	blacklist => serialized text => set (of words), 
	map (moving average parameters) => serialized text => hash [type, subset size, alpha coefficient]
}</pre>

<pre>
Feed => {
	belongs_to => category,
	has_many => feed_entries,
	name => string,
	url => string,
	alert => int,
	pop_mean => float,
	pop_sd => float,
	sample_mean => float,
	history => serialized text => int array,
	category_id => int
}
</pre>

<pre>
Feed Entry => {
	belongs_to => feed,
	name => string,
	summary => text,
	content => text,
	url => string,
	published_at => datetime,
	guid => int,
	feed_id => int
}
</pre>
