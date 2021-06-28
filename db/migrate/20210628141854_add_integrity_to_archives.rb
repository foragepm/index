class AddIntegrityToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :integrity, :string
  end
end
