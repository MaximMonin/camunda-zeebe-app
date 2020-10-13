class AddHasLocalPasswordToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :has_local_password, :boolean, default: true, null: false
  end
end
