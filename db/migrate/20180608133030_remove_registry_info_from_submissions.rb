class RemoveRegistryInfoFromSubmissions < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :registry_info, :json
  end
end
