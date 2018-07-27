class PreferUuidForTaskId < ActiveRecord::Migration[5.2]
  def change
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
  end
end
