require "application_system_test_case"

class AuthTest < ApplicationSystemTestCase
  test "auth" do
    visit new_user_session_url
    fill_in "user_email", with: users(:one).email
    fill_in "user_password", with: 'secret'
    click_on "commit"
    assert_text users(:one).username
    click_on users(:one).username
    click_on "Logout"
    assert_text "Signed out successfully."
  end
  test "register" do
    visit new_user_registration_url

    username = Faker::Name.name   
    email = Faker::Internet.email 

    fill_in "Email", with: email
    fill_in "User name", with: username
    fill_in "user_password", with: 'secret'
    fill_in "user_password_confirmation", with: 'secret'
    
    click_on "commit"
    assert_text "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    user = User.find_by_sql("SELECT * FROM users where users.email = '" + email + "'")

    visit '/users/confirmation?confirmation_token=' + user[0].confirmation_token

    visit new_user_session_url
    fill_in "user_email", with: email
    fill_in "user_password", with: 'secret'
    click_on "commit"
                                                                    
    assert_text username
    take_screenshot
  end
end
