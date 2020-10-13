require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "visit home" do
    get "/"
    assert_equal 200, status
    assert_select 'h1', "Welcome to Ruby on rails + Vue.js app"
  end
  test "init vue store" do
    get initstore_url, xhr: true

    r = JSON.parse(@response.body, symbolize_names: true)
    assert_equal 'en', r [:lang]
    assert_equal 'http://' + ENV['VIRTUAL_HOST'], r[:baseurl]
  end
end
