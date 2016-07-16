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

ActiveRecord::Schema.define(version: 20160716142356) do

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
    t.integer  "form_id"
    t.index ["form_id"], name: "index_cf0925s_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.integer  "province_id"
    t.string   "form_name"
    t.text     "form_description"
    t.string   "file_name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["province_id"], name: "index_forms_on_province_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
