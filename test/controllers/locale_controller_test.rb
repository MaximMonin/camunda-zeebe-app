require 'test_helper'

class LocaleControllerTest < ActionDispatch::IntegrationTest
  test "switch locales" do
    get "/"
    assert_equal 200, status
    assert_select 'h1', "Welcome to Ruby on rails + Vue.js app"
    get '/locale/ru'
    follow_redirect!
    assert_equal 200, status
    assert_select 'h1', "Добро пожаловать в приложение Ruby on rails + Vue.js"
    get '/locale/uk'
    follow_redirect!
    assert_equal 200, status
    assert_select 'h1', "Вітаємо у програмі Ruby on rails + Vue.js"
  end
end
