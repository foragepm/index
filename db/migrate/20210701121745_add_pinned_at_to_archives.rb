class AddPinnedAtToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :pinned_at, :datetime
  end
end
