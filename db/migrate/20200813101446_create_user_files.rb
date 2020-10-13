class CreateUserFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_files do |t|
      t.references :user, null: false, foreign_key: true
      t.text :file, default: "", null: false
      t.text :filepreview
      t.text :filename
      t.text :filetype
      t.integer :filesize, default: 0, null: false

      t.timestamps
    end
    add_index :user_files, :file, unique: true
    add_index :user_files, :filetype, unique: false
  end
end
