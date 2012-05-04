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

ActiveRecord::Schema.define(:version => 20120503204812) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

  add_index "authorizations", ["provider"], :name => "authorizations_provider_idx"
  add_index "authorizations", ["uid", "provider"], :name => "authorizations_uid_idx", :unique => true
  add_index "authorizations", ["user_id"], :name => "authorizations_user_id_idx"

  create_table "besties", :force => true do |t|
    t.string   "screen_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "besties", ["screen_name", "user_id"], :name => "besties_screen_name_idx", :unique => true
  add_index "besties", ["user_id"], :name => "besties_user_id_idx"

  create_table "followers", :force => true do |t|
    t.integer  "twitter_user_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followers", ["user_id", "twitter_user_id"], :name => "index_followers_on_user_id_and_twitter_user_id", :unique => true

  create_table "friends", :force => true do |t|
    t.integer  "twitter_user_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["user_id", "twitter_user_id"], :name => "index_friends_on_user_id_and_twitter_user_id", :unique => true

  create_table "interactions", :force => true do |t|
    t.string   "target"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "out_id"
  end

  add_index "interactions", ["out_id"], :name => "interactions_out_id_idx"
  add_index "interactions", ["user_id"], :name => "interactions_user_id_idx"

  create_table "mentions", :force => true do |t|
    t.integer  "user_id"
    t.string   "who"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "out_id"
  end

  add_index "mentions", ["out_id"], :name => "mentions_out_id_idx"
  add_index "mentions", ["user_id"], :name => "mentions_user_id_index"
  add_index "mentions", ["who", "user_id"], :name => "mentions_who_idx"

  create_table "out_hashtags", :force => true do |t|
    t.string   "tag"
    t.integer  "out_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "out_hashtags", ["out_id"], :name => "out_hashtags_out_id_idx"

  create_table "out_media", :force => true do |t|
    t.integer  "out_id"
    t.string   "media"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "out_media", ["out_id"], :name => "index_out_media_on_out_id"

  create_table "out_replies", :force => true do |t|
    t.string   "reply"
    t.integer  "out_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "out_replies", ["out_id"], :name => "out_replies_out_id_idx"

  create_table "out_targets", :force => true do |t|
    t.string   "target"
    t.integer  "out_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "out_targets", ["out_id"], :name => "out_targets_out_id_idx"

  create_table "out_trends", :force => true do |t|
    t.string   "trend"
    t.integer  "out_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "out_trends", ["out_id"], :name => "out_trends_out_id_idx"

  create_table "outs", :force => true do |t|
    t.string   "trend_source"
    t.string   "comment"
    t.string   "target"
    t.boolean  "twitter"
    t.boolean  "facebook"
    t.boolean  "youtube"
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content"
    t.boolean  "pending",      :default => false
    t.string   "type"
    t.string   "error"
  end

  add_index "outs", ["user_id"], :name => "outs_user_id_idx"
  add_index "outs", ["video_id"], :name => "outs_video_id_idx"

  create_table "replies", :force => true do |t|
    t.string   "status_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "out_id"
  end

  add_index "replies", ["out_id"], :name => "replies_out_id_idx"
  add_index "replies", ["status_id", "user_id"], :name => "replies_status_id_idx"
  add_index "replies", ["user_id"], :name => "replies_user_id_index"

  create_table "trendspottr_searches", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trendspottr_topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verified_twitter_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "verified_twitter_users", ["user_id"], :name => "index_verified_twitter_users_on_user_id"

  create_table "videos", :force => true do |t|
    t.string   "guid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "youtube_id"
    t.string   "bitly_uri"
  end

  add_index "videos", ["guid", "user_id"], :name => "videos_guid_idx", :unique => true
  add_index "videos", ["name", "user_id"], :name => "videos_name_idx", :unique => true
  add_index "videos", ["user_id"], :name => "videos_user_id_idx"

end
