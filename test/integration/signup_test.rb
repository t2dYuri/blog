require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup user data in form' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {name: '', email: 'user@invalid', password: 'foo', password_confirmation: 'bar'}
    end
    assert_template 'users/new'
    assert_select 'div.field_with_errors', count: 8
    assert_select 'div.alert'
  end


  test 'valid signup user data in form' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: 'Example User', email: 'user@example.com', password: 'f00baR', password_confirmation: 'f00baR' }
    end
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
    assert is_logged_in?
  end
end
