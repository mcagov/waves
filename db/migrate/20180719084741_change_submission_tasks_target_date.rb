class ChangeSubmissionTasksTargetDate < ActiveRecord::Migration[5.2]
  def change
    change_column :submission_tasks, :target_date, :date
  end
end
