require 'test_helper'

class ChatTest < ActiveSupport::TestCase
  test "new chat without data" do
    chat = Chat.new
    assert_not chat.save
  end
  test "new chat with name" do
    chat = Chat.new
    chat.name = "testchat"
    assert chat.save
  end
end
