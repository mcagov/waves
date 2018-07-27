class AddStartDateToSubmisionTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_tasks, :start_date, :date
  end
end
