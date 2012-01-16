# connects to database
def db_connect
	dbconfig = YAML::load(File.open('db/database.yml')) # load database config
	ActiveRecord::Base.establish_connection(dbconfig) # "connect" to db
end

# generates tables if there are none
def spawn_tables
	# pseudo-migration / schema
	if !FeedEntry.table_exists?
		print "Creating feed entry table...\n"
		ActiveRecord::Base.connection.create_table(:feed_entries) do |t|
			t.column :name, :string
			t.column :content, :string
			t.column :url, :string
			t.column :guid, :string
			t.column :published_at, :datetime
			t.column :feed_id, :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
	if !Feed.table_exists?
		print "Creating feed table...\n"
		ActiveRecord::Base.connection.create_table(:feeds) do |t|
			t.column :url, :string
			t.column :alert, :integer
			t.column :pop_stats, :text
			t.column :category_id, :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
	if !Blacklist.table_exists?
		print "Creating blacklist table...\n"
		ActiveRecord::Base.connection.create_table(:blacklists) do |t|
			t.column :word, :string
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
	if !Category.table_exists?
		print "Creating category table...\n"
		ActiveRecord::Base.connection.create_table(:categories) do |t|
			t.column :name, :string
			t.column :iteration, :integer
			t.column :word_stats, :text
			t.column :word_settings, :text
			t.column :feed_settings, :text
			t.column :map, :text
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
	if !Word.table_exists?
		print "Creating word table...\n"
		ActiveRecord::Base.connection.create_table(:words) do |t|
			t.column :name, :string
			t.column :alert, :integer
			t.column :pop_stats, :text
			t.column :category_id, :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
	if !Stat.table_exists?
		print "Creating stat table...\n"
		ActiveRecord::Base.connection.create_table(:stats) do |t|
			t.column :mean, :float
			t.column :sd, :float
			t.column :presence, :float
			t.column :statable_id, :integer
			t.column :statable_type, :string
			t.column :pop, :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end
end

# creates or adds feeds from feeds.txt
def spawn_feeds
	dir = File.dirname(File.dirname(__FILE__))
	Dir[dir+"/feeds/*.txt"].each do |file|
		filename = File.basename(file, ".txt")
		Category.create(:name => filename)
		cat_id = Category.find_by_name(filename).id		
		File.open(file, "r").each_line do |line|
			Feed.create(:url => line.strip, :category_id => cat_id ) unless !Feed.find_by_url_and_category_id(line.strip, cat_id).nil?
		end
	end
end

# creates or adds blacklist items from blacklist.txt
def spawn_blacklist
	File.open("../blacklist.txt", "r").each_line do |line|
		Blacklist.create(:word => line.strip) unless !Blacklist.find_by_word(line.strip).nil?
	end
end
