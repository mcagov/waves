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

ActiveRecord::Schema.define(version: 20160516135857) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "address_1",  null: false
    t.string   "address_2"
    t.string   "address_3"
    t.string   "town",       null: false
    t.string   "county"
    t.string   "postcode",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owner_addresses", force: :cascade do |t|
    t.integer  "owner_id"
    t.integer  "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owner_vessels", force: :cascade do |t|
    t.integer  "owner_id"
    t.integer  "vessel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owners", force: :cascade do |t|
    t.string   "title",         null: false
    t.string   "forename",      null: false
    t.string   "surname",       null: false
    t.string   "nationality",   null: false
    t.string   "email",         null: false
    t.string   "phone_number"
    t.string   "mobile_number", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "register_vessels", force: :cascade do |t|
    t.integer  "register_id"
    t.integer  "vessel_id"
    t.string   "status",          null: false
    t.datetime "expiry_date",     null: false
    t.integer  "register_number", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "registers", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.string   "ip_country",   null: false
    t.string   "card_country", null: false
    t.string   "browser",      null: false
    t.string   "payment_id",   null: false
    t.string   "receipt_id"
    t.string   "status",       null: false
    t.datetime "due_date",     null: false
    t.boolean  "is_urgent",    null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_vessel_registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "vessel_registration_id"
    t.json     "changes",                default: {}, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "ldap_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vessel_registrations", force: :cascade do |t|
    t.integer  "vessel_id"
    t.integer  "registration_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "vessel_types", force: :cascade do |t|
    t.string   "designation", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "vessels", force: :cascade do |t|
    t.string   "name",                  null: false
    t.string   "hin"
    t.string   "make_and_model"
    t.integer  "length_in_centimeters", null: false
    t.integer  "number_of_hulls",       null: false
    t.integer  "vessel_type_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

end