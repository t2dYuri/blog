require 'test_helper'

class UserPageTest < ActionDispatch::IntegrationTest
  # include ApplicationHelper

  def setup
    @user = users(:trend)
    @second_user = users(:second)
    @admin = users(:admin)
  end

  test "user's page template" do
    log_in_as(@user)
    get user_path(@user)
    assert_response :success
    assert_template 'users/show'
    assert_template partial: 'shared/_user_info_current'
    assert_template partial: 'shared/_followers_current'
    assert_template partial: 'articles/_all_my_articles_list'
    assert_select 'title', full_title(@user.name)
    delete logout_path
    log_in_as(@second_user)
    get user_path(@user)
    assert_template partial: 'shared/_user_info_other'
    assert_template partial: 'shared/_followers_other'
  end

  test "user's page for current user" do
    log_in_as(@user)
    get user_path(@user)
    # user's info section
    assert_select 'h3', text: @user.name
    assert_select 'h3>img.avatar'
    assert_match /default.jpg/i, response.body
    assert_match @user.articles.count.to_s, response.body
    assert_select 'a.edit-but[href=?]', edit_user_path(@user), 1
    assert_select 'a.btn-main[href=?]', new_article_path, 1
    # user's articles section
    assert_select 'div#art-ajax-paginate' do
      @user.articles.paginate(page: 1).per_page(10).each do |article|
        assert_select 'span.art-date', (article.updated_at.strftime '%d-%m-%Y в %H:%M')
        assert_select 'a.show-but[href=?]', article_path(article), 1
        assert_select 'a[href=?]', article_path(article), article.title, 1
        assert_select 'a[href=?]', edit_article_path(article)
        assert_select 'a[data-method=delete][href=?]', article_path(article), 1
      end
    end
    assert_select 'div.paginator'
  end

  test "user's page for other users, only differences" do
    log_in_as(@second_user)
    get user_path(@user)
    assert_select 'a.edit-but[href=?]', edit_user_path(@user), 0
    assert_select 'a.btn-main[href=?]', new_article_path, 0
    @user.articles.paginate(page: 1).per_page(10).each do |article|
      assert_select 'a[data-method=delete][href=?]', article_path(article), 0
      assert_select 'a[href=?]', edit_article_path(article), 0
    end
  end

  test 'follow section for current user' do
    log_in_as(@user)
    get user_path(@user)
    assert_select 'img.avatar[src=?]', '/assets/icon_default.jpg', 4
    # following
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a.show-but[href=?]', user_path(user)
      assert_match user.articles.count.to_s, response.body
    end
    # followers
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a.show-but[href=?]', user_path(user)
      assert_match user.articles.count.to_s, response.body
    end
  end

  test 'follow section for other user, only differences' do
    log_in_as(@second_user)
    get user_path(@user)
    assert_no_match /following/i, response.body
    assert_match /followers/i, response.body
  end

  test "user's page for admin, only differences" do
    log_in_as(@admin)
    get user_path(@user)
    assert_select 'a.edit-but[href=?]', edit_user_path(@user), 1
    @user.followers.each do |user|
      assert_select 'a[href=?]', edit_user_path(user), 1
      assert_select 'a[data-method=delete][href=?]', user_path(user), 1
    end
    @user.articles.paginate(page: 1).per_page(10).each do |article|
      assert_select 'a.edit-but[href=?]', edit_article_path(article), 1
      assert_select 'a[data-method=delete][href=?]', article_path(article), 1
    end
  end

  test 'following and unfollowing other user, without ajax' do
    log_in_as(@user)
    get user_path(@second_user)
    # watching follow form with correct elements at other user's page
    assert_select 'form.new_relationship', 1
    assert_select 'form.edit_relationship', 0
    assert_select 'input[type=hidden][name=?]', 'followed_id', 1
    assert_select 'input.btn-main[type=submit][name=?]', 'commit', 1
    # following other user and checking follow count
    assert_difference '@user.following.count', +1 do
      assert_difference '@second_user.followers.count', +1 do
        post relationships_path, followed_id: @second_user.id
      end
    end
    assert_redirected_to @second_user
    follow_redirect!
    # watching unfollow form with correct elements at other user's page
    assert_select 'form.new_relationship', 0
    assert_select 'form.edit_relationship', 1
    assert_select 'input.btn-unfollow[type=submit][name=?]', 'commit', 1
    # unfollowing other user and checking follow count
    relationship = @user.active_relationships.find_by(followed_id: @second_user.id)
    assert_difference '@user.following.count', -1 do
      assert_difference '@second_user.followers.count', -1 do
        delete relationship_path(relationship)
      end
    end
    assert_redirected_to @second_user
    follow_redirect!
    # watching initial form with correct elements at other user's page
    assert_select 'form.new_relationship', 1
    assert_select 'form.edit_relationship', 0
    assert_select 'input.btn-main[type=submit][name=?]', 'commit', 1
  end

  test 'following and unfollowing other user, with ajax' do
    log_in_as(@user)
    assert_difference '@user.following.count', +1 do
      assert_difference '@second_user.followers.count', +1 do
        xhr :post, relationships_path, followed_id: @second_user.id
      end
    end
    assert_response :success
    relationship = @user.active_relationships.find_by(followed_id: @second_user.id)
    assert_difference '@user.following.count', -1 do
      assert_difference '@second_user.followers.count', -1 do
        xhr :delete, relationship_path(relationship)
      end
    end
    assert_response :success
  end
end
