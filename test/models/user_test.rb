require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "new user without data" do
    user = User.new
    assert_not user.save
  end
  test "new user with email only" do
    user = User.new
    user.email = "test@domain.com"
    assert_not user.save
  end
  test "new user with email and username only" do
    user = User.new
    user.email = "test@domain.com"
    user.username = "test name"
    assert_not user.save
  end
  test "new user with email, username and password" do
    user = User.new
    user.email = "test@domain.com"
    user.username = "test name"
    user.password = user.password_confirmation = "secret"
    assert user.save
  end
end
