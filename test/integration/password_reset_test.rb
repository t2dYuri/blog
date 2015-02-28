require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:trend)
  end

  test 'password reset' do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Bad email
    post password_resets_path, password_reset: { email: '' }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Good email
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    user = assigns(:user)

    # Bad email
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Good email, bad token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # Good email, good token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email

    # Bad password & confirmation
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'qwerty', password_confirmation: 'ytrewq' }
    assert_select 'div#error_explanation'

    # Blank password
    patch password_reset_path(user.reset_token), email: user.email, user: { password: '  ', password_confirmation: 'foobar' }
    assert_not flash.empty?
    assert_template 'password_resets/edit'

    # Good password & confirmation
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'qwerty', password_confirmation: 'qwerty' }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test 'expired password reset token' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 4.hours.ago)
    patch password_reset_path(@user.reset_token), email: @user.email, user: { password: 'f00baR', password_confirmation: 'f00baR' }
    assert_response :redirect
    follow_redirect!
    assert_select '.alert-danger'
    assert_match /Время сброса пароля истекло/i, response.body
  end
end
