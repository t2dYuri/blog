require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users(:trend)
    @second_user = users(:second)
    @admin = users(:admin)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should redirect from edit user when not logged in' do
    get :edit, id: @user
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from update user when not logged in' do
    patch :update, id: @user, user: {name: @user.name, email: @user.email}
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from edit when wrong user' do
    log_in_as(@second_user)
    get :edit, id: @user
    assert_redirected_to root_url
    assert flash.empty?
  end

  test 'should redirect from update when wrong user' do
    log_in_as(@second_user)
    patch :update, id: @user, user: {name: @user.name, email: @user.email}
    assert_redirected_to root_url
    assert flash.empty?
  end

  test 'should redirect from users index when not logged in' do
    get :index
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from destroy user when not logged in' do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from destroy user when non-admin' do
    log_in_as(@second_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test 'should destroy user when admin' do
    log_in_as(@admin)
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
    assert_redirected_to users_url
    assert_not flash.empty?
  end

  test 'should not allow to destroy user itself' do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test 'should not allow to destroy admin itself' do
    log_in_as(@admin)
    assert_no_difference 'User.count' do
      delete :destroy, id: @admin
    end
    assert_redirected_to root_url
  end

  test 'should not allow to appoint admin attribute' do
    log_in_as(@user)
    assert_not @user.admin?
    patch :update, id: @user, user: {password: 'foobar',
                                     password_confirmation: 'foobar',
                                     admin: true}
    assert_not @user.reload.admin?
  end
end
