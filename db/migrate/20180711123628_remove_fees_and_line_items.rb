class RemoveFeesAndLineItems < ActiveRecord::Migration[5.2]
  def change
    drop_table "fees", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "category"
      t.string "task_variant"
      t.integer "price", default: 0
      t.integer "premium_addon_price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "subsequent_price"
      t.index ["category"], name: "index_fees_on_category"
      t.index ["task_variant"], name: "index_fees_on_task_variant"
    end

    drop_table "line_items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "submission_id"
      t.uuid "fee_id"
      t.integer "price"
      t.integer "premium_addon_price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
