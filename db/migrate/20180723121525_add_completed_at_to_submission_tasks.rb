class AddCompletedAtToSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_tasks, :completed_at, :datetime
  end
end
