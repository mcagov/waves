class UpdateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :name
      t.integer :standard_days
      t.integer :premium_days
      t.json :part_1, default: nil
      t.json :part_2, default: nil
      t.json :part_3, default: nil
      t.json :part_4, default: nil
    end
  end
end
