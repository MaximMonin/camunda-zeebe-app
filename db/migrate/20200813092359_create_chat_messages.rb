class CreateChatMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message
      t.text :files

      t.timestamps
    end
    add_index :chat_messages, :created_at, unique: false
  end
end
