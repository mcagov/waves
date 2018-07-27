class TasksHaveWorkLogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :work_logs, :submission_id, :uuid, index: true
    add_column :work_logs, :submission_task_id, :uuid, index: true
  end
end
