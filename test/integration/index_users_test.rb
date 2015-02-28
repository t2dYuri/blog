require 'test_helper'

class IndexUsersTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
    @admin = users(:admin)
  end

  test 'users index for non-admin with pagination' do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.paginator'
    assert_select 'ul#users-ajax' do
      assert_select 'li.li-zebra', 15
      assert_select 'img.avatar', 15
      assert_select 'a.show-but', 15
      assert_select 'a.edit-but', 0...1
      assert_select 'a.del-but', 0
    end

    User.paginate(page: 1).per_page(15).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test 'users index for admin with pagination, edit and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'ul#users-ajax' do
      assert_select 'a.edit-but', 15
      assert_select 'a.del-but', 14...15
    end

    User.paginate(page: 1).per_page(15).each do |user|
      assert_select 'a[href=?]', edit_user_path(user)
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), method: :delete
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end
  end
end
