class RenameTaskToApplicationType < ActiveRecord::Migration[5.2]
  def change
    rename_column :finance_payments, :task, :application_type
    rename_column :submissions, :document_entry_task, :application_type
  end
end
