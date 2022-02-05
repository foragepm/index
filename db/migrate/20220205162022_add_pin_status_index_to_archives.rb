class AddPinStatusIndexToArchives < ActiveRecord::Migration[6.1]
  def change
    add_index :archives, :pin_status
  end
end
