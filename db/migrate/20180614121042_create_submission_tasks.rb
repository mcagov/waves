class CreateSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_tasks, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :service_id, index: true
      t.uuid :submission_id, index: true
      t.uuid :claimant_id, index: true
      t.string :ref_no, index: true
      t.datetime :referred_until
      t.timestamps
    end
  end
end
