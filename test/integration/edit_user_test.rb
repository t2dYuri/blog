require 'test_helper'

class EditUserTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
  end

  test 'edit user form view' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_response :success
    assert_template 'users/edit'
    assert_select 'a.close[href=?]', user_path(@user)
    assert_select 'h4.modal-title', /.+#{@user.name}/
    assert_select 'form.edit_user' do
      assert_select 'label[for=?]', 'user_name', 1
      assert_select 'label[for=?]', 'user_email', 0
      assert_select 'label[for=?]', 'user_password', 1
      assert_select 'label[for=?]', 'user_password_confirmation', 1
      assert_select 'input[type=text][name=?][value=?]', 'user[name]', "#{@user.name}", 1
      assert_select 'input[type=email][name=?][value=?]', 'user[email]', "#{@user.email}", 0
      assert_select 'input[type=password][name=?]', 'user[password]', 1
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]', 1
      assert_select 'img.avatar[src=?]', '/assets/default.jpg', 1
      assert_select 'input.file-upload[type=text][accept=?][name=?]',
                    'image/jpeg,image/gif,image/png', 'user[remote_avatar_url]', 1
      assert_select 'input[type=file][accept=?][name=?]', 'image/jpeg,image/gif,image/png', 'user[avatar]', 1
      assert_select 'input[type=hidden][name=?]', 'user[avatar_cache]', 1
      assert_select 'input[type=checkbox][name=?]', 'user[remove_avatar]', 1
      assert_select 'input[type=text][name=?]', 'user[about_me]', 1
      assert_select 'input[type=date][name=?]', 'user[birth_date]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
    end
  end

  test 'invalid data in edit user form' do
    log_in_as(@user)
    get edit_user_path(@user)

    # bad name
    patch user_path(@user), user: { name: '' }
    assert_template 'users/edit'
    assert_select 'div#error_explanation' do
      assert_select 'div.alert'
    end
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=text][name=?][value=?]', 'user[name]', ''
    end

    # corrected name, short password
    patch user_path(@user), user: { name: 'Good Name', password: 'foo', password_confirmation: 'foo' }
    assert_select 'h4.modal-title', /.+Good Name/
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=password][name=?]', 'user[password]'
    end

    # corrected password, wrong password_confirmation
    patch user_path(@user), user: { password: 'foobsr', password_confirmation: 'FOOBAR' }
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=password][name=?]', 'user[password_confirmation]'
    end
    get user_path(@user)
    assert_not_equal @user.name, 'Good Name'
  end

  test 'successful edit user with secondary params and friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = 'Test Edit'
    email = 'tryto@changemail.com'
    about_me = 'edit about me'
    birth_date = '24.03.1981'
    patch user_path(@user), user: {name: name, email: email, about_me: about_me, birth_date: birth_date}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.about_me, about_me
    assert_equal @user.birth_date, birth_date
    # checking that initial email still active and try to pass new one was failed
    assert_not_equal @user.email, email
    assert_equal @user.email, 'trend@example.com'
  end

  test 'successful edit user when current user is admin' do
    log_in_as(users(:admin))
    get edit_user_path(@user)
    assert_select 'label[for=?]', 'user_email', 1
    assert_select 'input[type=email][name=?][value=?]', 'user[email]', "#{@user.email}", 1
    patch user_path(@user), user: {email: 'change@email.com', password: 'qwerty', password_confirmation: 'qwerty'}
    @user.reload
    assert_equal @user.email, 'change@email.com'
  end

  test 'new avatar remains in cache after invalid form reloading' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_match /default.jpg/i, response.body
    patch user_path(@user), user: {name: '', avatar: fixture_file_upload('test/fixtures/avatest.jpg', 'image/jpeg')}
    assert_template 'users/edit'
    assert_select 'div.field_with_errors'
    assert_match /avatest.jpg/, response.body
  end

  # disabling this test because it uploads avatar each time to dedicated server
  # test 'showing and uploading user avatar' do
  #   log_in_as(@user)
  #   get user_path(@user)
  #   assert_not @user.avatar?
  #   assert_match /default.jpg/i, response.body
  #   get edit_user_path(@user)
  #   patch user_path(@user), user: {avatar: fixture_file_upload('test/fixtures/avatest.jpg', 'image/jpeg')}
  #   follow_redirect!
  #   @user.reload
  #   assert @user.avatar?
  #   assert_match /avatest.jpg/, response.body
  # end
end
