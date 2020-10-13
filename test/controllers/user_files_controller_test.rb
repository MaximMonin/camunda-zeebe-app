require 'test_helper'

class UserFilesControllerTest < ActionDispatch::IntegrationTest
  test "visit files without login" do
    get user_file_url ('photos')
    assert_equal 302, status
    assert_redirected_to new_user_session_url
  end
  test "visit user photo with login" do
    sign_in users(:one), 'secret'
    get user_file_url ('photos'), xhr: true
    assert_equal 200, status

    r = JSON.parse(@response.body, symbolize_names: true)
    assert_equal 'cdn/user1/1.jpg', r[0][:file]
    assert_equal 'cdn/user1/preview_1.jpg', r[0][:filepreview]
    assert_equal '1.jpg', r[0][:filename]
    assert_equal 'image/jpeg', r[0][:filetype]
    assert_equal 10000, r[0][:filesize]
  end
  test "visit user video with login" do
    sign_in users(:one), 'secret'
    get user_file_url ('videos'), xhr: true
    assert_equal 200, status

    r = JSON.parse(@response.body, symbolize_names: true)
    assert_equal [], r
  end
  test "visit user docs with login" do
    sign_in users(:one), 'secret'
    get user_file_url ('docs'), xhr: true
    assert_equal 200, status

    r = JSON.parse(@response.body, symbolize_names: true)
    assert_equal [], r
  end
  test "visit user other with login" do
    sign_in users(:one), 'secret'
    get user_file_url ('other'), xhr: true
    assert_equal 200, status
    r = @response.body
    assert_equal 'error', r
  end
end
