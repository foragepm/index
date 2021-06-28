class CreateArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :archives do |t|
      t.references :version, null: false, foreign_key: true, index: true
      t.references :package, null: false, foreign_key: true, index: true
      t.string :url
      t.integer :size
      t.string :cid

      t.timestamps
    end
  end
end
