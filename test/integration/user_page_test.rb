require 'test_helper'

class UserPageTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:trend)
    @second_user = users(:second)
  end

  test "show user's page to all users" do
    log_in_as(@second_user)
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h3', text: @user.name
    assert_select 'h3>img.avatar'
    assert_match /default.jpg/i, response.body
    assert_match @user.articles.count.to_s, response.body
    assert_select 'div#art-ajax-paginate' do
      @user.articles.paginate(page: 1).per_page(10).each do |article|
        assert_match (article.updated_at.strftime '%d-%m-%Y в %H:%M'), response.body
        assert_select 'a[href=?]', article_path(article), 2
        assert_select 'a[href=?]', edit_article_path(article), false
        assert_select 'a.del-but[href=?]', article_path(article), false
      end
    end
    assert_select 'div.paginator'
  end

  test "show user's page to current user with edit/delete links" do
    log_in_as(@user)
    get user_path(@user)
    assert_select 'a.edit-but[href=?]', edit_user_path(@user), 1
    assert_select 'a.btn-main[href=?]', new_article_path, 1
    assert_select 'div#art-ajax-paginate' do
      @user.articles.paginate(page: 1).per_page(10).each do |article|
        assert_select 'a[href=?]', edit_article_path(article)
        assert_select 'a.del-but[href=?]', article_path(article)
      end
    end
  end
end
