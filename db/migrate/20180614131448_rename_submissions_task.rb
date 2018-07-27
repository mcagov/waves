class RenameSubmissionsTask < ActiveRecord::Migration[5.2]
  def change
    rename_column :submissions, :task, :document_entry_task
  end
end
