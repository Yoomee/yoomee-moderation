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

ActiveRecord::Schema.define(:version => 20110719161834) do

  create_table "content_flag_fields", :force => true do |t|
    t.integer  "content_flag_id"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_flag_types", :force => true do |t|
    t.string "name"
    t.string "color", :default => "#2795E4"
  end

  create_table "content_flaggings", :force => true do |t|
    t.integer  "content_flag_id"
    t.integer  "content_flag_type_id"
    t.integer  "user_id"
    t.text     "message"
    t.string   "email"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_flags", :force => true do |t|
    t.string   "url"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.integer  "resolved_by_id"
    t.datetime "resolved_at"
    t.datetime "opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string  "name"
    t.boolean "admin", :default => false
  end

end
