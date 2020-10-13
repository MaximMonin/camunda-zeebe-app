require 'test_helper'

class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  test "visit chat messages without login" do
    get chat_message_url (chats(:one).id)
    assert_equal 302, status
    assert_redirected_to new_user_session_url
  end
  test "visit chat messages with login" do
    sign_in users(:one), 'secret'
    get chat_message_url (chats(:one).id), xhr: true
    assert_equal 200, status
    r = JSON.parse(@response.body, symbolize_names: true)
    assert_equal 'First message', r[0][:message]
  end
end
