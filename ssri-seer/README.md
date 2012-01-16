#SSRI-Seer (Small-Scale, Rails Independent Seer) Readme

SSRI-Seer is a small-scale, Rails-independent development version of Seer. ActiveRecord is still used for handling the database and models. SSRI-Seer is a testing ground for developing Seer's core logic and collecting sample data. Except for feed fetching (accomplished via FeedZirra), everything is offline.

###Usage
Run from the command line:
    <pre>$ ruby main.rb [arguments]</pre>

Accepted arguments:
	<pre>
	feeds => returns all feeds with their id, category, url, and number of entries
	blacklist => returns all blacklist words
	feed [ID] => returns all entries for a feed with the given [ID] and total number of entries
	word [WORD] => returns the full stat history for the given [WORD]
	categories => returns all categories with feeds, number of feeds, and number of words
	update => updates all feeds, returns how many entries were added
	spawn => will create the database & populate with categories, feeds, and blacklist items
	migrate => will update the database with newly added feeds or blacklist items
	test => will destroy the database, spawn a new one, and update the feeds
	</pre>


###Notes
Feeds and blacklist items are read from text files. When either of these files are changed, you must run the "migrate" command:
	<pre>$ ruby main.rb migrate</pre>

- blacklist.txt contains blacklisted words
- Each category has it's own text file in feeds/. The category name is taken from the text filename.
NOTE: Removing items from the text files will not remove them from the database.

- db/migrate.db contains the methods for managing the (offline) database. These will be replaced by Rails-native functions in the true Seer.
- core.db contains the core methods. The core methods will be moved to their appropriate models soon. They contain a lot of command-line specific notifications that will be removed when they're ported to the true Seer.


###To Do
- Population stat tracking for words
- Feed stat tracking
- Category word stat tracking
- Output to CSV command, or graph output functions
- Keep track of unique word count
- Automatic/scheduled updates
  



