class AddYankedToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :yanked, :boolean, default: false
  end
end
