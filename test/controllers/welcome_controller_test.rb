require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  def setup
    @base_title = 'BloGG'
  end

  test 'welcome routes' do
    assert_routing '/'       , controller: 'welcome', action: 'index'
    assert_routing '/help'   , controller: 'welcome', action: 'help'
    assert_routing '/about'  , controller: 'welcome', action: 'about'
    assert_routing '/contact', controller: 'welcome', action: 'contact'
  end

  test 'wanna get Welcome page' do
    get :index
    assert_response :success
    assert_select 'title', "#{@base_title}"
  end

  test 'wanna get help page' do
    get :help
    assert_response :success
    assert_select 'title', "Help | #{@base_title}"
  end

  test 'wanna get about page' do
    get :about
    assert_response :success
    assert_select 'title', "About | #{@base_title}"
  end

  test 'wanna get contact page' do
    get :contact
    assert_response :success
    assert_select 'title', "Contact | #{@base_title}"
  end
end
