class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :key, index: true
      t.string :name, index: true
    end
  end
end
