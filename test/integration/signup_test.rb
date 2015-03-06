require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'signup page template and form elements' do
    get signup_path
    assert_response :success
    assert_template 'users/new'
    assert_select 'title', full_title('Регистрация')
    assert_select 'a.close[href=?]', '/', 1 do
      assert_select 'i.glyphicon'
    end
    assert_select 'form.new_user' do
      assert_select 'label[for=?]', 'user_name', 1
      assert_select 'label[for=?]', 'user_email', 1
      assert_select 'label[for=?]', 'user_password', 1
      assert_select 'label[for=?]', 'user_password_confirmation', 1
      assert_select 'input[type=text][name=?]', 'user[name]', 1
      assert_select 'input[type=email][name=?]', 'user[email]', 1
      assert_select 'input[type=password][name=?]', 'user[password]', 1
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
    end
    assert_select 'a.btn-default[href=?]', login_path, 1
  end

  test 'invalid signup user data in form' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: '', email: '', password: '', password_confirmation: '' }
    end
    assert_response :success
    assert_template 'users/new'
    # getting 4 errors: nil name, nil email, wrong email type and too short password
    assert_select 'div#error_explanation' do
      assert_select 'div.alert'
    end
    assert_select 'ul#errors-list' do
      assert_select 'li', 4
    end
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=text][name=?][value=?]', 'user[name]', ''
      assert_select 'input[type=email][name=?][value=?]', 'user[email]', ''
      assert_select 'input[type=password][name=?]', 'user[password]'
    end
    assert_no_difference 'User.count' do
      post users_path, user: { name: 'Fixed Name',
                               email: 'fixed@email.com',
                               password: 'qwerty',
                               password_confirmation: 'foobar' }
    end
    # getting 1 error: Password confirmation doesn't match Password
    assert_select 'ul#errors-list>li', 1
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]'
    end
    # more details in test 'invalid data in edit user form' in test/integration/edit_user_test.rb
  end


  test 'valid signup user data in form' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: 'Example User',
                               email: 'user@example.com',
                               password: 'f00baR',
                               password_confirmation: 'f00baR' }
    end
    assert_not flash.empty?

    # user activation steps
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?

    # Invalid activation token
    get edit_account_activation_path('invalid token')
    assert_not is_logged_in?

    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
