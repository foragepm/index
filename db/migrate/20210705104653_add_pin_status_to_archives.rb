class AddPinStatusToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :pin_status, :string
  end
end
