class AddStateToSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_tasks, :state, :string, index: true
  end
end
