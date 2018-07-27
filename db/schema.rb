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

ActiveRecord::Schema.define(version: 2018_07_25_090654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "assets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "owner_id"
    t.string "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "file_updated_at"
    t.integer "file_file_size"
    t.string "file_content_type"
    t.string "file_file_name"
    t.index ["owner_id"], name: "index_assets_on_owner_id"
    t.index ["owner_type"], name: "index_assets_on_owner_type"
  end

  create_table "carving_and_markings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "delivery_method"
    t.uuid "actioned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "template"
  end

  create_table "charterers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "parent_id"
    t.string "parent_type"
    t.string "reference_number"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_sessions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "external_session_key"
    t.string "vessel_reg_no"
    t.integer "access_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "customer_id"
    t.index ["external_session_key"], name: "index_client_sessions_on_external_session_key"
    t.index ["vessel_reg_no"], name: "index_client_sessions_on_vessel_reg_no"
  end

  create_table "csr_forms", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.uuid "vessel_id"
    t.integer "issue_number"
    t.datetime "issued_at"
    t.string "flag_state", default: "United Kingdom"
    t.datetime "registered_at"
    t.string "vessel_name"
    t.string "port_name"
    t.string "owner_names"
    t.string "owner_addresses"
    t.string "owner_identification_number"
    t.string "charterer_names"
    t.string "charterer_addresses"
    t.string "manager_name"
    t.string "manager_address"
    t.string "safety_management_address"
    t.string "manager_company_number"
    t.string "classification_societies"
    t.string "document_of_compliance_issuer"
    t.string "document_of_compliance_auditor"
    t.string "smc_issuer"
    t.string "smc_auditor"
    t.string "issc_issuer"
    t.string "issc_auditor"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "registration_closed_at"
  end

  create_table "custom_auto_increments", id: :serial, force: :cascade do |t|
    t.string "counter_model_name"
    t.integer "counter", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "counter_model_scope"
    t.index ["counter_model_name", "counter_model_scope"], name: "counter_model_name_scope", unique: true
    t.index ["counter_model_name"], name: "index_custom_auto_increments_on_counter_model_name"
  end

  create_table "customers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "type"
    t.string "email"
    t.string "name"
    t.string "nationality"
    t.string "phone_number"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imo_number"
    t.string "eligibility_status"
    t.string "registration_number"
    t.datetime "date_of_incorporation"
    t.boolean "managing_owner", default: false
    t.boolean "correspondent", default: false
    t.string "entity_type", default: "individual"
    t.integer "shares_held"
    t.uuid "parent_id"
    t.string "parent_type"
    t.string "alt_address_1"
    t.string "alt_address_2"
    t.string "alt_address_3"
    t.string "alt_town"
    t.string "alt_country"
    t.string "alt_postcode"
    t.boolean "custom_boolean", default: false
    t.index ["email"], name: "index_customers_on_email"
    t.index ["type"], name: "index_customers_on_type"
  end

  create_table "declaration_group_members", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "declaration_owner_id"
    t.uuid "declaration_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "declaration_groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.integer "shares_held", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "declarations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "notification_id"
    t.datetime "completed_at"
    t.uuid "completed_by_id"
    t.string "entity_type", default: "individual"
    t.integer "shares_held", default: 0
    t.uuid "registered_owner_id"
    t.index ["completed_by_id"], name: "index_declarations_on_completed_by_id"
    t.index ["notification_id"], name: "index_declarations_on_notification_id"
    t.index ["state"], name: "index_declarations_on_state"
    t.index ["submission_id"], name: "index_declarations_on_submission_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "engines", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "parent_id"
    t.string "parent_type"
    t.string "engine_type"
    t.string "make"
    t.string "model"
    t.integer "cylinders"
    t.string "derating"
    t.integer "rpm"
    t.decimal "mcep_per_engine"
    t.decimal "mcep_after_derating"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_type"], name: "index_engines_on_parent_type"
  end

  create_table "finance_batches", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "finance_payment_id"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.uuid "processed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "batch_no"
    t.datetime "locked_at"
    t.string "state"
    t.index ["finance_payment_id"], name: "index_finance_batches_on_finance_payment_id"
  end

  create_table "finance_payments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "part"
    t.string "application_type"
    t.string "vessel_name"
    t.string "payment_type"
    t.decimal "payment_amount"
    t.string "applicant_name"
    t.string "applicant_email"
    t.string "documents_received"
    t.uuid "actioned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "payment_date"
    t.string "vessel_reg_no"
    t.boolean "applicant_is_agent", default: false
    t.string "application_ref_no"
    t.uuid "batch_id"
    t.string "payer_name"
    t.integer "service_level", default: 0
    t.index ["actioned_by_id"], name: "index_finance_payments_on_actioned_by_id"
  end

  create_table "mortgages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "parent_id"
    t.string "parent_type"
    t.string "mortgage_type"
    t.string "reference_number"
    t.datetime "executed_at"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "priority_code"
    t.datetime "registered_at"
    t.datetime "discharged_at"
    t.index ["parent_type"], name: "index_mortgages_on_parent_type"
  end

  create_table "name_approvals", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "part"
    t.string "name"
    t.string "port_code"
    t.integer "port_no"
    t.string "registration_type"
    t.datetime "approved_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cancelled_at"
    t.index ["name"], name: "index_name_approvals_on_name"
    t.index ["part"], name: "index_name_approvals_on_part"
    t.index ["port_code"], name: "index_name_approvals_on_port_code"
  end

  create_table "notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "noteable_id"
    t.string "noteable_type"
    t.uuid "actioned_by_id"
    t.string "type"
    t.string "subject"
    t.string "format"
    t.datetime "noted_at"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "entity_type"
    t.string "issuing_authority"
    t.datetime "expires_at"
    t.index ["actioned_by_id"], name: "index_notes_on_actioned_by_id"
    t.index ["entity_type"], name: "index_notes_on_entity_type"
    t.index ["noteable_id"], name: "index_notes_on_noteable_id"
    t.index ["noteable_type"], name: "index_notes_on_noteable_type"
    t.index ["type"], name: "index_notes_on_type"
  end

  create_table "notifications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "type"
    t.string "subject"
    t.text "body"
    t.uuid "actioned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "notifiable_id"
    t.string "notifiable_type"
    t.string "recipient_name"
    t.string "recipient_email"
    t.string "attachments"
    t.string "state"
    t.datetime "delivered_at"
    t.datetime "approved_at"
    t.uuid "approved_by_id"
    t.index ["notifiable_id"], name: "index_notifications_on_notifiable_id"
    t.index ["notifiable_type"], name: "index_notifications_on_notifiable_type"
    t.index ["type"], name: "index_notifications_on_type"
  end

  create_table "payments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remittance_type"
    t.uuid "remittance_id"
    t.integer "amount"
    t.index ["remittance_id"], name: "index_payments_on_remittance_id"
    t.index ["remittance_type"], name: "index_payments_on_remittance_type"
    t.index ["submission_id"], name: "index_payments_on_submission_id"
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.uuid "searchable_id"
    t.string "searchable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_id"], name: "index_pg_search_documents_on_searchable_id"
    t.index ["searchable_type"], name: "index_pg_search_documents_on_searchable_type"
  end

  create_table "print_jobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "printable_id"
    t.string "printable_type"
    t.string "template"
    t.uuid "printed_by_id"
    t.datetime "printed_at"
    t.string "part"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "state"
    t.uuid "printing_by_id"
    t.datetime "printing_at"
    t.uuid "submission_id"
    t.index ["printable_id"], name: "index_print_jobs_on_printable_id"
    t.index ["printable_type"], name: "index_print_jobs_on_printable_type"
    t.index ["template"], name: "index_print_jobs_on_template"
  end

  create_table "registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "vessel_id"
    t.datetime "registered_at"
    t.datetime "registered_until"
    t.uuid "actioned_by_id"
    t.json "registry_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "closed_at"
    t.text "description"
    t.datetime "renewal_reminder_at"
    t.datetime "expiration_reminder_at"
    t.datetime "termination_at"
    t.boolean "provisional", default: false
    t.string "supporting_info"
    t.index ["vessel_id"], name: "index_registrations_on_vessel_id"
  end

  create_table "sequence_numbers", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "context"
    t.string "generated_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context"], name: "index_sequence_numbers_on_context"
    t.index ["generated_number"], name: "index_sequence_numbers_on_generated_number"
    t.index ["type"], name: "index_sequence_numbers_on_type"
  end

  create_table "services", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.integer "standard_days"
    t.integer "premium_days"
    t.json "part_1"
    t.json "part_2"
    t.json "part_3"
    t.json "part_4"
  end

  create_table "shareholder_group_members", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "shareholder_group_id"
    t.uuid "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shareholder_groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "vessel_id"
    t.integer "shares_held"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submission_tasks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "service_id"
    t.uuid "submission_id"
    t.uuid "claimant_id"
    t.datetime "referred_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price", default: 0
    t.integer "submission_ref_counter"
    t.date "target_date"
    t.string "state"
    t.integer "service_level", default: 0
    t.date "start_date"
    t.datetime "completed_at"
    t.index ["claimant_id"], name: "index_submission_tasks_on_claimant_id"
    t.index ["service_id"], name: "index_submission_tasks_on_service_id"
    t.index ["submission_id"], name: "index_submission_tasks_on_submission_id"
  end

  create_table "submissions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "delivery_address_id"
    t.json "changeset"
    t.string "part"
    t.string "state"
    t.uuid "claimant_id"
    t.datetime "referred_until"
    t.string "ref_no"
    t.datetime "received_at"
    t.uuid "registered_vessel_id"
    t.string "applicant_name"
    t.string "applicant_email"
    t.boolean "applicant_is_agent", default: false
    t.string "documents_received"
    t.uuid "correspondent_id"
    t.uuid "managing_owner_id"
    t.datetime "carving_and_marking_received_at"
    t.uuid "registration_id"
    t.datetime "completed_at"
    t.string "application_type"
    t.string "source"
    t.index ["claimant_id"], name: "index_submissions_on_claimant_id"
    t.index ["part"], name: "index_submissions_on_part"
    t.index ["ref_no"], name: "index_submissions_on_ref_no"
    t.index ["state"], name: "index_submissions_on_state"
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "access_level", default: 0
    t.boolean "disabled", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vessels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "hin"
    t.string "make_and_model"
    t.string "number_of_hulls"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mmsi_number"
    t.string "radio_call_sign"
    t.string "vessel_type"
    t.decimal "length_in_meters"
    t.string "reg_no"
    t.string "part"
    t.datetime "frozen_at"
    t.string "registration_type"
    t.string "port_code"
    t.integer "port_no"
    t.decimal "net_tonnage"
    t.decimal "gross_tonnage"
    t.decimal "register_tonnage"
    t.string "vessel_category"
    t.string "imo_number"
    t.string "last_registry_country"
    t.string "last_registry_no"
    t.string "last_registry_port"
    t.string "classification_society"
    t.string "classification_society_other"
    t.datetime "entry_into_service_at"
    t.string "area_of_operation"
    t.string "alternative_activity"
    t.string "propulsion_system"
    t.string "name_of_builder"
    t.string "builders_address"
    t.string "place_of_build"
    t.datetime "keel_laying_date"
    t.string "hull_construction_material"
    t.string "year_of_build"
    t.string "country_of_build"
    t.string "underlying_registry"
    t.string "underlying_registry_identity_no"
    t.string "underlying_registry_port"
    t.string "smc_issuing_authority"
    t.string "smc_auditor"
    t.string "issc_issuing_authority"
    t.string "issc_auditor"
    t.string "name_on_primary_register"
    t.decimal "register_length"
    t.decimal "length_overall"
    t.decimal "breadth"
    t.decimal "depth"
    t.string "doc_issuing_authority"
    t.string "doc_auditor"
    t.uuid "current_registration_id", default: -> { "uuid_generate_v4()" }
    t.string "state"
    t.index ["hin"], name: "index_vessels_on_hin"
    t.index ["mmsi_number"], name: "index_vessels_on_mmsi_number"
    t.index ["name"], name: "index_vessels_on_name"
    t.index ["part"], name: "index_vessels_on_part"
    t.index ["radio_call_sign"], name: "index_vessels_on_radio_call_sign"
    t.index ["reg_no"], name: "index_vessels_on_reg_no"
    t.index ["registration_type"], name: "index_vessels_on_registration_type"
    t.index ["vessel_type"], name: "index_vessels_on_vessel_type"
  end

  create_table "work_logs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.json "logged_info"
    t.string "logged_type"
    t.string "description"
    t.uuid "actioned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "part"
    t.uuid "submission_task_id"
    t.index ["actioned_by_id"], name: "index_work_logs_on_actioned_by_id"
    t.index ["logged_type"], name: "index_work_logs_on_logged_type"
  end

  create_table "world_pay_payments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "customer_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "wp_order_code"
  end

end
