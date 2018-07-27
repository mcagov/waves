class RemoveLinkAbleRefNo < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :linkable_ref_no, :string
  end
end
