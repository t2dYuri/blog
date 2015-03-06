require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
  end

  test 'login page template and form elements' do
    get login_path
    assert_response :success
    assert_template 'sessions/new'
    assert_select 'title', full_title('Вход')
    assert_select 'a.close[href=?]', '/', 1 do
      assert_select 'i.glyphicon'
    end
    assert_select 'form[action=?]', login_path do
      assert_select 'label[for=?]', 'session_email', 1
      assert_select 'label[for=?]', 'session_password', 1
      assert_select 'label.checkbox[for=?]', 'session_remember_me', 1
      assert_select 'input[type=email][name=?]', 'session[email]', 1
      assert_select 'input[type=password][name=?]', 'session[password]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
      assert_select 'input[type=hidden][name=?][value=?]', 'session[remember_me]', '0', 1
      assert_select 'input[type=checkbox][name=?][value=?]', 'session[remember_me]', '1', 1
    end
    assert_select 'a[href=?]', new_password_reset_path, 1
    assert_select 'a.btn-default[href=?]', signup_path, 1
  end

  test 'invalid login user data in form' do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: '', password: '' }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'valid login user and logout user' do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'welcome/index'
    assert_select 'a[href=?]', login_path, 0
    assert_select 'a[href=?]', logout_path, 1
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path, 1
    assert_select 'a[href=?]', logout_path, 0
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
