class CreateSocials < ActiveRecord::Migration[6.0]
  def change
    create_table :socials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :username
      t.string :email
      t.string :weblink
      t.column :data, :json

      t.timestamps
    end
    add_index :socials, [:user_id, :provider, :uid], unique: true
    add_index :socials, :provider, unique: false
    add_index :socials, :uid, unique: false
  end
end
