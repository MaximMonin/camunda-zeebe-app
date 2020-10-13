require 'test_helper'

class UserFileTest < ActiveSupport::TestCase
  test "new userfile without data" do
    userfile = UserFile.new
    assert_not userfile.save
  end
  test "new userfile with file" do
    userfile = UserFile.new
    userfile.user = User.first
    assert_not userfile.save
  end
  test "new userfile with file data" do
    userfile = UserFile.new
    userfile.user = User.first
    userfile.file = 'test.jpg'
    userfile.filename = 'test.jpg'
    userfile.filetype = 'image/jpeg'
    userfile.filesize = 10000
    assert userfile.save
  end
end
