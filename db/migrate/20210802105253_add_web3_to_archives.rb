class AddWeb3ToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :web3, :boolean, default: false
  end
end
