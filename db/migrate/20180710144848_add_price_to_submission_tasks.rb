class AddPriceToSubmissionTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_tasks, :price, :integer, default: 0
  end
end
