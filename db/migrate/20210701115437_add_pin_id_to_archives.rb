class AddPinIdToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :pin_id, :integer
  end
end
