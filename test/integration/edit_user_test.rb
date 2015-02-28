require 'test_helper'

class EditUserTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
  end

  test 'edit user form view' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    assert_select 'a.close[href=?]', user_path(@user)
    assert_select 'form.edit_user' do
      assert_select "label[for='user_name']"
      assert_select "input[type=text][value='#{@user.name}'][name='user[name]']"
      assert_select "label[for='user_email']"
      assert_select "input[type=email][value='#{@user.email}'][name='user[email]']"
      assert_select "input[type=password][name='user[password]']"
      assert_select "input[type=password][name='user[password_confirmation]']"
      assert_select "img.avatar[src='/assets/default.jpg'][alt='Default']"
      assert_select "input.file-upload[type=text][accept='image/jpeg,image/gif,image/png'][name='user[remote_avatar_url]']"
      assert_select "input[type=file][accept='image/jpeg,image/gif,image/png'][name='user[avatar]']"
      assert_select "input[type=hidden][name='user[avatar_cache]']"
      assert_select "input[type=checkbox][name='user[remove_avatar]']"
      assert_select "input[type=text][name='user[about_me]']"
      assert_select "input[type=date][name='user[birth_date]']"
      assert_select "input[type=submit][name='commit']"
    end
  end

  test 'invalid data in edit form' do
    log_in_as(@user)
    get edit_user_path(@user)
    patch user_path(@user), user: {name: '', email: 'mail@invalid', password: 'foo', password_confirmation: 'bar'}
    assert_template 'users/edit'
    assert_select 'div.field_with_errors'
    assert_select 'div.alert'
  end

  test 'successful edit user with secondary params and friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = 'Test Edit'
    email = 'mail@edit.com'
    about_me = 'edit about me'
    birth_date = '24.03.1981'
    patch user_path(@user), user: {name: name, email: email, about_me: about_me, birth_date: birth_date, password: 'f00baR', password_confirmation: 'f00baR'}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
    assert_equal @user.about_me, about_me
    assert_equal @user.birth_date, birth_date
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
