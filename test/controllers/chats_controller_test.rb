require 'test_helper'

class ChatsControllerTest < ActionDispatch::IntegrationTest
  test "visit chat without login" do
    get chats_url ()
    assert_equal 302, status
    assert_redirected_to new_user_session_url
  end
  test "visit chat with login" do
    sign_in users(:one), 'secret'
    get chats_url ()
    assert_equal 200, status
    assert_select 'h4', "Welcome to chat"
    assert_select 'a', chats(:one).name
  end
  test "visit chat one" do
    sign_in users(:one), 'secret'
    get chat_url (chats(:one).id)
    assert_equal 200, status
    assert_select 'h2', chats(:one).name
    css_select("chatrow") do |elements|
      elements.each do |element|
        assert_select element, "p", chat_messages(:one).message
      end
    end
  end
  test "visit chat two" do
    sign_in users(:one), 'secret'
    get chat_url (chats(:two).id)
    assert_equal 200, status
    assert_select 'h2', chats(:two).name
    css_select("chatrow") do |elements|
      elements.each do |element|
        assert_select element, "p", chat_messages(:two).message
      end
    end
  end
  test "edit chat name" do
    sign_in users(:one), 'secret'
    get edit_chat_url (chats(:one).id)
    assert_equal 200, status
    assert_select 'h2', 'Edit room ' + chats(:one).name
  end
  test "add new chat" do
    @chatname = 'third chat'
    sign_in users(:one), 'secret'
    get new_chat_url ()
    assert_equal 200, status
    assert_select 'h2', 'New Chat Room'
    post chats_path \
      "chat[name]"    => @chatname
    follow_redirect!
    assert_equal 200, status
    assert_select 'a', @chatname

    # select new chat room
    @chat = Chat.where(name: @chatname).first
    get chat_url (@chat.id)
    assert_select 'h2', @chatname
    # no message in new chat room
    assert_equal 0, css_select("chatrow").length
  end
end
