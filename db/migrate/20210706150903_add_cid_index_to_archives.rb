class AddCidIndexToArchives < ActiveRecord::Migration[6.1]
  def change
    add_index :archives, :cid
  end
end
