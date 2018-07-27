class MoveServiceLevelToSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :service_level, :string
    add_column :submission_tasks, :service_level, :integer, default: 0
  end
end
