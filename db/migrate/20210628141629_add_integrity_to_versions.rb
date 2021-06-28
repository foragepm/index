class AddIntegrityToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :integrity, :string
  end
end
