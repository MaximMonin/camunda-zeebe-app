require "application_system_test_case"

class ChatTest < ApplicationSystemTestCase
  test "chat basic test" do
    visit new_user_session_url
    fill_in "user_email", with: users(:one).email
    fill_in "user_password", with: 'secret'
    click_on "commit"
    click_on users(:one).username
    click_on "Chat Rooms"
    assert_text "Welcome to chat"
    click_on chats(:one).name
    page.has_content?('Enter message')

    # begin chatting in window

    fill_in "chattext", with: 'Hello, i am ' + users(:one).username
    click_on 'sendmessage'

    assert_text 'Hello, i am ' + users(:one).username
    attach_file('file', Rails.root.join('test/fixtures/files/profile.jpg'), make_visible: true)
    attach_file('file', Rails.root.join('test/fixtures/files/video.mp4'), make_visible: true)
    fill_in "chattext", with: 'Here is a photo and video'
    assert_text "Delete (2)"
    click_on 'sendmessage'
    assert_text 'video.mp4'
    assert_text 'profile.jpg'
    assert_text 'Here is a photo and video'

    take_screenshot
  end
  test "chat vue test" do
    visit new_user_session_url
    fill_in "user_email", with: users(:one).email
    fill_in "user_password", with: 'secret'
    click_on "commit"

    visit chat_url (chats(:one).id)

    attach_file('file', Rails.root.join('test/fixtures/files/profile.jpg'), make_visible: true)
    attach_file('file', Rails.root.join('test/fixtures/files/video.mp4'), make_visible: true)
    assert_text "Delete (2)"

    find('#removefiles').hover
    assert_text 'video.mp4'
    assert_text 'profile.jpg'
    take_screenshot

    click_on "removefiles"

    assert has_no_button?('Delete')
  end
  test "communication" do
    visit new_user_session_url
    fill_in "user_email", with: users(:one).email
    fill_in "user_password", with: 'secret'
    click_on "commit"

    visit chat_url (chats(:one).id)

    using_session("user2") do
      visit new_user_session_url
      fill_in "user_email", with: users(:two).email
      fill_in "user_password", with: 'secret2'
      click_on "commit"

      visit chat_url (chats(:one).id)
    end

    username = Faker::Name.name   
    username2 = Faker::Name.name   

    fill_in "chattext", with: 'Hello, i am ' + username
    click_on 'sendmessage'

    using_session("user2") do
      assert_text 'Hello, i am ' + username
      fill_in "chattext", with: 'Hi ' + username2
      click_on 'sendmessage'
    end

    assert_text 'Hi ' + username2
    fill_in "chattext", with: 'I am not ' + username2
    click_on 'sendmessage'

    using_session("user2") do
      assert_text 'I am not ' + username2
    end
    take_screenshot
  end
end
