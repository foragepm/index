class CreateDeals < ActiveRecord::Migration[6.1]
  def change
    create_table :deals do |t|
      t.integer :deal_id
      t.bigint :size
      t.integer :files_count
      t.string :cid

      t.timestamps
    end
  end
end
