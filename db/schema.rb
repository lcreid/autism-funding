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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160716210132) do

  create_table "addresses", force: :cascade do |t|
    t.integer  "province_code_id"
    t.integer  "user_id"
    t.text     "address_line_1",   limit: 40
    t.text     "address_line_2",   limit: 40
    t.text     "city",             limit: 40
    t.text     "postal_code",      limit: 6
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["province_code_id"], name: "index_addresses_on_province_code_id"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "forms", force: :cascade do |t|
    t.integer  "province_code_id"
    t.text     "file_name",        limit: 50,  null: false
    t.text     "form_description"
    t.text     "form_name",        limit: 100, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["province_code_id"], name: "index_forms_on_province_code_id"
  end

  create_table "funded_people", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "birthdate"
    t.text     "name_first",  limit: 50
    t.text     "name_last",   limit: 50
    t.text     "name_middle", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_funded_people_on_user_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.integer  "phone_number_type_id"
    t.integer  "user_id"
    t.text     "phone_extension",      limit: 10
    t.text     "phone_number",         limit: 10
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "phone_type",           limit: 25
    t.index ["phone_number_type_id"], name: "index_phone_numbers_on_phone_number_type_id"
    t.index ["user_id"], name: "index_phone_numbers_on_user_id"
  end

  create_table "province_codes", force: :cascade do |t|
    t.text     "not_supported", limit: 1
    t.text     "province_code", limit: 2
    t.text     "province_name", limit: 50
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "name_first",             limit: 50
    t.text     "name_last",              limit: 50
    t.text     "name_middle",            limit: 50
    t.text     "role",                   limit: 15
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
