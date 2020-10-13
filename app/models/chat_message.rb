class ChatMessage < ApplicationRecord
  belongs_to :chat, inverse_of: :chat_messages
  belongs_to :user, inverse_of: :chat_messages
  include Searchable
end
