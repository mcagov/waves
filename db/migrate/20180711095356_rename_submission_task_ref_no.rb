class RenameSubmissionTaskRefNo < ActiveRecord::Migration[5.2]
  def change
    remove_column :submission_tasks, :ref_no, :string
    add_column :submission_tasks, :submission_ref_counter, :integer
  end
end
