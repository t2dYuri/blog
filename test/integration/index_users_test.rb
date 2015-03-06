# "all articles index when not logged in" test located in test/integration/index_articles_test.rb
# because it's code is equal to this page

require 'test_helper'

class IndexUsersTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
    @admin = users(:admin)
  end

  test 'users index page template' do
    log_in_as(@user)
    get users_path
    assert_response :success
    assert_select 'title', full_title('Все пользователи')
    assert_template 'users/index'
    assert_template partial: 'users/_user'
    assert_template partial: 'articles/_all_articles'
  end

  test 'users index for non-admin with pagination' do
    log_in_as(@user)
    get users_path
    assert_select 'ul#users-ajax>li.li-zebra' do
      User.paginate(page: 1).per_page(10).each do |user|
        if user == @user
          assert_select 'a.edit-but[href=?]', edit_user_path(user), 1
        else
          assert_select 'a.edit-but[href=?]', edit_user_path(user), 0
        end
        assert_select 'img.avatar[src=?]', user.avatar.url(:icon)
        assert_select 'a[href=?]', user_path(user), text: user.name, count: 1
        assert_select 'a.show-but[href=?]', user_path(user), 1
        assert_select 'a.del-but[data-method=delete][href=?]', user_path(user), 0
        assert_select 'span#user-art-count', user.articles.count.to_s, 1
      end
    end
    assert_select 'div.paginator'
  end

  test 'users index for admin, only differences ' do
    log_in_as(@admin)
    get users_path
    assert_select 'ul#users-ajax>li.li-zebra' do
      User.paginate(page: 1).per_page(10).each do |user|
        assert_select 'a[href=?]', edit_user_path(user), 1
        unless user == @admin
          assert_select 'a[data-method=delete][href=?]', user_path(user), 1
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end
    assert_redirected_to users_url
    assert_not flash.empty?
  end
end
