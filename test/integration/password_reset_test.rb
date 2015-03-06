require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:trend)
  end

  test 'password reset page template and form elements' do
    get new_password_reset_path
    assert_response :success
    assert_template 'password_resets/new'
    assert_select 'title', full_title('Сброс пароля')
    assert_select 'a.close[href=?]', '/', 1 do
      assert_select 'i.glyphicon'
    end
    assert_select 'form[action=?]', password_resets_path do
      assert_select 'label[for=?]', 'password_reset_email', 1
      assert_select 'input[type=email][name=?]', 'password_reset[email]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
    end
    assert_select 'a.btn-default[href=?]', login_path, 1
  end

  test 'password reset process' do
    get new_password_reset_path

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

    # Good email, good token, password edit form view
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'title', full_title('Новый пароль')
    assert_select 'a.close[href=?]', root_path, 1 do
      assert_select 'i.glyphicon'
    end
    assert_select 'form.edit_user' do
      assert_select 'label[for=?]', 'user_password', 1
      assert_select 'label[for=?]', 'user_password_confirmation', 1
      assert_select 'input[type=hidden][name=?][value=?]', 'email', user.email, 1
      assert_select 'input[type=password][name=?]', 'user[password]', 1
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
    end

    # Bad password & confirmation
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'qwerty',
                                                                            password_confirmation: 'ytrewq' }
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation' do
      assert_select 'div.alert'
    end
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]', 1
    end

    # Blank password
    patch password_reset_path(user.reset_token), email: user.email, user: { password: '  ',
                                                                            password_confirmation: 'foobar' }
    assert_not flash.empty?
    assert_match /Пароль не может быть пустым/, response.body

    # Good password & confirmation, redirecting to user page
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'qwerty',
                                                                            password_confirmation: 'qwerty' }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test 'expired password reset token' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 4.hours.ago)
    patch password_reset_path(@user.reset_token), email: @user.email, user: { password: 'f00baR',
                                                                              password_confirmation: 'f00baR' }
    assert_response :redirect
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_not flash[:danger].empty?
    assert_match /Время сброса пароля истекло/i, response.body
  end
end
