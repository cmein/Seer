#!/usr/bin/env ruby

require "rubygems"
require "active_record"
require "sqlite3"
require 'yaml'
require "stringio"
require "ox"

require "~/seer/ruby/testparsing/datachunk" # datachunk.rb
require "~/seer/ruby/testparsing/saxer" # saxer.rb

# setup new DB if none exists
MY_DB_NAME = ".my.db"
MY_DB = SQLite3::Database.new(MY_DB_NAME)

dbconfig = YAML::load(File.open('database.yml')) # load database config
ActiveRecord::Base.establish_connection(dbconfig) # "connect" to db

# pseudo-migration / schema
if !Datachunk.table_exists?
  p "Creating table..."
  ActiveRecord::Base.connection.create_table(:datachunks) do |t|
    t.column :course_title, :string
  end
end

# parse an XML
io = StringIO.new(File.read('datasets/reed.xml')) # load XML into a IO stream
handler = Saxer.new()
Ox.sax_parse(handler, io) # SAX parsing


p Datachunk.find(:all)

