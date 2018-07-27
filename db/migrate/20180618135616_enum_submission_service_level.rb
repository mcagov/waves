class EnumSubmissionServiceLevel < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :service_level, :string
    add_column :submissions, :service_level, :integer
  end
end
