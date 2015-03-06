require 'test_helper'

class IndexArticlesTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:trend)
    @admin = users(:admin)
  end

  test 'articles index page template' do
    get articles_path
    assert_response :success
    assert_select 'title', full_title('Все статьи')
    assert_template 'articles/index'
    assert_template partial: 'articles/_all_articles'
  end

  test 'all articles index when not logged in' do
    get articles_path
    assert_select 'div#art-ajax-paginate' do
      assert_select 'ul.list-unstyled>li.li-zebra' do
        Article.paginate(page: 1).per_page(10).each do |article|
          assert_select 'span[title=?]', "Автор: #{article.user.name}" do
            assert_select 'img.avatar[src=?]', article.user.avatar.url(:icon)
          end
          assert_select 'span.art-date', (article.updated_at.strftime '%d-%m-%Y в %H:%M')
          assert_select 'a.show-but[href=?]', article_path(article), 1
          assert_select 'a[href=?]', article_path(article), article.title, 1
          assert_select 'a[href=?]', edit_article_path(article), 0
          assert_select 'a[data-method=delete][href=?]', article_path(article), 0
          assert_select 'a[href=?]', user_path(article.user), 0
          assert_match article.description.first(10), response.body
        end
      end
      assert_select 'div.paginator'
    end
  end

  test 'all articles index when logged in, only differences' do
    log_in_as(@user)
    get articles_path
    Article.paginate(page: 1).per_page(10).each do |article|
      if article.user == @user
        assert_select 'a[href=?]', edit_article_path(article), 1
        assert_select 'a[data-method=delete][href=?]', article_path(article), 1
      else
        assert_select 'a[href=?]', edit_article_path(article), 0
        assert_select 'a[data-method=delete][href=?]', article_path(article), 0
      end
      assert_select 'a[title=?][href=?]', "Автор: #{article.user.name}", user_path(article.user) do
        assert_select 'img.avatar[src=?]', article.user.avatar.url(:icon)
      end
    end
  end

  test 'all articles index for admin, only differences' do
    log_in_as(@admin)
    get articles_path
    Article.paginate(page: 1).per_page(10).each do |article|
      assert_select 'a[title=?][href=?]', "Автор: #{article.user.name}", user_path(article.user) do
        assert_select 'img.avatar[src=?]', article.user.avatar.url(:icon)
      end
      assert_select 'a[href=?]', edit_article_path(article), 1
      assert_select 'a[data-method=delete][href=?]', article_path(article), 1
    end
    assert_difference 'Article.count', -1 do
      delete article_path(articles(:art1))
    end
  end
end
