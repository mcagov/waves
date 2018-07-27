class RemoveTargetDateFromSubmissions < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :target_date, :datetime
  end
end
