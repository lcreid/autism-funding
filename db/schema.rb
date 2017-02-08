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

ActiveRecord::Schema.define(version: 20170208220042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "province_code_id"
    t.integer  "user_id"
    t.text     "address_line_1"
    t.text     "address_line_2"
    t.text     "city"
    t.text     "postal_code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["province_code_id"], name: "index_addresses_on_province_code_id", using: :btree
    t.index ["user_id"], name: "index_addresses_on_user_id", using: :btree
  end

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
    t.integer  "funded_person_id"
    t.string   "part_b_fiscal_year"
    t.index ["form_id"], name: "index_cf0925s_on_form_id", using: :btree
    t.index ["funded_person_id"], name: "index_cf0925s_on_funded_person_id", using: :btree
  end

  create_table "forms", force: :cascade do |t|
    t.integer  "province_code_id"
    t.text     "file_name",        null: false
    t.text     "form_description"
    t.text     "form_name",        null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "class_name"
    t.index ["province_code_id"], name: "index_forms_on_province_code_id", using: :btree
  end

  create_table "funded_people", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "birthdate"
    t.text     "name_first"
    t.text     "name_last"
    t.text     "name_middle"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "child_in_care_of_ministry"
    t.index ["user_id"], name: "index_funded_people_on_user_id", using: :btree
  end

  create_table "invoice_allocations", force: :cascade do |t|
    t.integer "cf0925_id"
    t.integer "invoice_id"
    t.decimal "amount",      precision: 7, scale: 2
    t.string  "cf0925_type"
    t.index ["cf0925_id", "invoice_id"], name: "index_invoice_allocations_on_cf0925_id_and_invoice_id", using: :btree
    t.index ["cf0925_id"], name: "index_invoice_allocations_on_cf0925_id", using: :btree
    t.index ["invoice_id", "cf0925_id"], name: "index_invoice_allocations_on_invoice_id_and_cf0925_id", using: :btree
    t.index ["invoice_id"], name: "index_invoice_allocations_on_invoice_id", using: :btree
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "cf0925_id"
    t.decimal  "invoice_amount",        precision: 7, scale: 2
    t.date     "invoice_date"
    t.string   "notes"
    t.date     "service_end"
    t.date     "service_start"
    t.string   "invoice_reference"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "funded_person_id"
    t.string   "supplier_name"
    t.text     "agency_name"
    t.text     "service_provider_name"
    t.string   "invoice_from"
    t.index ["cf0925_id"], name: "index_invoices_on_cf0925_id", using: :btree
    t.index ["funded_person_id"], name: "index_invoices_on_funded_person_id", using: :btree
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "phone_extension"
    t.text     "phone_number"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "phone_type"
    t.index ["user_id"], name: "index_phone_numbers_on_user_id", using: :btree
  end

  create_table "province_codes", force: :cascade do |t|
    t.text     "not_supported"
    t.text     "province_code"
    t.text     "province_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
    t.text     "name_first"
    t.text     "name_last"
    t.text     "name_middle"
    t.text     "role"
    t.text     "preferences"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "addresses", "province_codes"
  add_foreign_key "addresses", "users"
  add_foreign_key "cf0925s", "forms"
  add_foreign_key "cf0925s", "funded_people"
  add_foreign_key "forms", "province_codes"
  add_foreign_key "funded_people", "users"
  add_foreign_key "invoices", "cf0925s"
  add_foreign_key "invoices", "funded_people"
  add_foreign_key "phone_numbers", "users"
end
