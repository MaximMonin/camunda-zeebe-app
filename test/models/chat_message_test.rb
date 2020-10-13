require 'test_helper'

class ChatMessageTest < ActiveSupport::TestCase
  test "new chatmessage without data" do
    chatmessage = ChatMessage.new
    assert_not chatmessage.save
  end
  test "new chatmessage without message and files" do
    chatmessage = ChatMessage.new
    chatmessage.user = User.first
    chatmessage.chat = Chat.first
    assert chatmessage.save
  end
end
