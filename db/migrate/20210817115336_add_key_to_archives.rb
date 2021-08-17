class AddKeyToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :key, :string
    add_index :archives, :key
  end
end
