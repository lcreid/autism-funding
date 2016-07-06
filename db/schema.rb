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

ActiveRecord::Schema.define(version: 20160701013926) do

  create_table "cf0925s", force: :cascade do |t|
    t.string   "agency_name"
    t.string   "child_dob"
    t.string   "child_first_name"
    t.string   "child_last_name"
    t.string   "child_middle_name"
    t.boolean  "child_in_care_of_ministry"
    t.string   "home_phone"
    t.decimal  "item_cost_1",                     precision: 7, scale: 2
    t.decimal  "item_cost_2",                     precision: 7, scale: 2
    t.decimal  "item_cost_3",                     precision: 7, scale: 2
    t.string   "item_desp_1"
    t.string   "item_desp_2"
    t.string   "item_desp_3"
    t.string   "parent_address"
    t.string   "parent_city"
    t.string   "parent_first_name"
    t.string   "parent_last_name"
    t.string   "parent_middle_name"
    t.string   "parent_postal_code"
    t.string   "payment"
    t.string   "service_provider_postal_code"
    t.string   "service_provider_address"
    t.string   "service_provider_city"
    t.string   "service_provider_phone"
    t.string   "service_provider_name"
    t.string   "service_provider_service_1"
    t.string   "service_provider_service_2"
    t.string   "service_provider_service_3"
    t.decimal  "service_provider_service_amount", precision: 7, scale: 2
    t.date     "service_provider_service_end"
    t.decimal  "service_provider_service_fee",    precision: 7, scale: 2
    t.string   "service_provider_service_hour"
    t.date     "service_provider_service_start"
    t.string   "supplier_address"
    t.string   "supplier_city"
    t.string   "supplier_contact_person"
    t.string   "supplier_name"
    t.string   "supplier_phone"
    t.string   "supplier_postal_code"
    t.string   "work_phone"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "forms", force: :cascade do |t|
    t.string   "form_name",        limit: 100, null: false
    t.string   "form_description"
    t.string   "file_name",        limit: 50,  null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "funded_people", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "birthdate"
    t.string   "name_first",  limit: 50
    t.string   "name_last",   limit: 50
    t.string   "name_middle", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_funded_people_on_user_id"
  end

  create_table "province_codes", force: :cascade do |t|
    t.string   "prov_code",     limit: 2
    t.string   "not_supported", limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "province_name", limit: 25
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
    t.integer  "province_code_id"
    t.string   "role",                   limit: 15
    t.string   "address_line_1",         limit: 40
    t.string   "address_line_2",         limit: 40
    t.string   "city",                   limit: 40
    t.string   "postal_code",            limit: 6
    t.string   "name_first",             limit: 50
    t.string   "name_last",              limit: 50
    t.string   "name_middle",            limit: 50
    t.string   "phone_number",           limit: 10
    t.string   "phone_extension",        limit: 10
    t.string   "work_phone_number",      limit: 10
    t.string   "work_phone_extension",   limit: 10
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["province_code_id"], name: "index_users_on_province_code_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
