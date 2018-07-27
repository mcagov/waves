class RemoveOfficerInterventionRequired < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :officer_intervention_required, default: false
  end
end
