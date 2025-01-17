# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120103145114) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "iteration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "alert_threshold"
    t.text     "word_settings"
    t.text     "feed_settings"
    t.text     "word_stats"
    t.text     "map"
  end

  create_table "feed_entries", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "content"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id"
  end

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "alert"
    t.float    "pop_mean"
    t.float    "sample_mean"
    t.text     "history"
    t.float    "pop_sd"
  end

  create_table "words", :force => true do |t|
    t.string   "name"
    t.integer  "alert"
    t.float    "pop_mean"
    t.float    "pop_sd"
    t.text     "history"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
