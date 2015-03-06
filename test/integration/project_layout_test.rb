require 'test_helper'

class ProjectLayoutTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:trend)
  end

  test 'rendering layouts' do
    get root_path
    assert_response :success
    assert_template 'welcome/index'
    assert_template layout: 'layouts/application'
    assert_template partial: 'layouts/_shim'
    assert_template partial: 'layouts/_header'
    assert_template partial: 'layouts/_search_form'
  end

  test 'layout links and icons' do
    # not logged in
    get root_path
    assert_select 'header.navbar-fixed-top' do
      assert_select 'i.glyphicon', 5
      assert_select 'a[href=?]', root_path, 1
      assert_select 'div.btn-group ul.dropdown-menu li' do
        assert_select 'a[href=?]', help_path, 1
        assert_select 'a[href=?]', about_path, 1
        assert_select 'a[href=?]', contact_path, 1
      end
      assert_select 'div.btn-group ul.dropdown-menu li' do
        assert_select 'a[href=?]', articles_path, 1
        assert_select 'a[href=?]', '#', text: 'Поиск статьи', count: 1
        assert_select 'a[href=?]', new_article_path, 0
      end
      assert_select 'a[href=?]', users_path, 0
      assert_select 'div.btn-group ul.dropdown-menu li' do
        assert_select 'a[href=?]', user_path(@user), 0
        assert_select 'a[href=?]', edit_user_path(@user), 0
        assert_select 'a[href=?]', logout_path, 0
      end
      assert_select 'a[href=?]', login_path, 1
      assert_select 'a[href=?]', signup_path, 1
    end
    get signup_path
    assert_select 'title', full_title('Регистрация')
    get login_path
    assert_select 'title', full_title('Вход')

    # logging in as user
    log_in_as(@user)
    get root_path
    assert_select 'header.navbar-fixed-top' do
      assert_select 'a[href=?]', login_path, 0
      assert_select 'a[href=?]', signup_path, 0
      assert_select 'a[href=?]', new_article_path, 1
      assert_select 'a[href=?]', users_path, 1
      assert_select 'a[href=?]', user_path(@user), 1
      assert_select 'a[href=?]', edit_user_path(@user), 1
      assert_select 'a[href=?]', logout_path, 1
      assert_select 'a', text: "#{@user.name}", count: 1
    end
  end

  test 'search form appearance & functionality' do

    default  = articles(:art4)
    result_1 = articles(:art2)
    result_2 = articles(:third_art2)
    result_3 = articles(:second_art2)
    # first article by default order "updated_at, desc" in DB must be 'art4'
    assert_equal Article.first, default
    # checking as it is in article-index-list (default pagination: 10 per page)
    get articles_path
    assert_select 'div#art-ajax-paginate ul.list-unstyled' do
      assert_select 'li', 10
      assert_select 'li:first-child' do
        assert_select 'a[href=?]', article_path(default), text: default.title, count: 1
      end
    end
    # checking search-form
    assert_select 'form.search-form' do
      assert_select 'input[type=text][name=?]', 'query'
      assert_select 'input[type=submit][name=?]', 'search'
    end
    # sending request with query 'article two'.
    # At result-page must be 3 articles, according to order: art2, third_art2, second_art2
    get articles_path, query: 'article two'
    assert_response :success
    assert_template 'articles/index'
    assert_select 'div#art-ajax-paginate ul.list-unstyled' do
      assert_select 'li', 3
      assert_select 'li:first-child' do
        assert_select 'a[href=?]', article_path(result_1), text: result_1.title, count: 1
        assert_select 'span.art-date', (result_1.updated_at.strftime '%d-%m-%Y в %H:%M')
        assert_match result_1.description, response.body
      end
      assert_select 'li:nth-child(2)' do
        assert_select 'a[href=?]', article_path(result_2), text: result_2.title, count: 1
        assert_select 'span.art-date', (result_2.updated_at.strftime '%d-%m-%Y в %H:%M')
        assert_match result_2.description, response.body
      end
      assert_select 'li:last-child' do
        assert_select 'a[href=?]', article_path(result_3), text: result_3.title, count: 1
        assert_select 'span.art-date', (result_3.updated_at.strftime '%d-%m-%Y в %H:%M')
        assert_match result_3.description, response.body
      end
    end
    assert_no_match default.title, response.body
  end
end
