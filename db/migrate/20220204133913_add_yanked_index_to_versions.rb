class AddYankedIndexToVersions < ActiveRecord::Migration[6.1]
  def change
    add_index :versions, :yanked
  end
end
