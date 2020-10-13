class AddFilesUpdatedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :files_updated_at, :datetime
  end
end
