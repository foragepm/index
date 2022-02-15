class AddDigestMatchToArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :digest_match, :boolean
  end
end
