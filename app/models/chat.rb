class Chat < ApplicationRecord
  validates :name, presence: true  
  has_many :chat_messages, dependent: :destroy, inverse_of: :chat
  audited
end
