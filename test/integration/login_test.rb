require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
  end

  test 'invalid login user data in form' do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: {email: '', password: ''}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'valid login user and logout user' do
    get login_path
    post login_path, session: {email: @user.email, password: 'password'}
    assert is_logged_in?
    assert_redirected_to root_path
    follow_redirect!
    assert_template 'welcome/index'
    assert_select 'a[href=?]', users_path
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', user_path(@user)
    assert_select 'a[href=?]', edit_user_path(@user)
    assert_select 'a[href=?]', logout_path
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path

    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
    assert_select 'a[href=?]', users_path, count: 0
  end

  test 'login with remember user' do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test 'login without remember user' do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
