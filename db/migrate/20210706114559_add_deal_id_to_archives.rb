class AddDealIdToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :deal_id, :integer
  end
end
