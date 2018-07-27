class AddTargetDateToSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_tasks, :target_date, :datetime
  end
end
