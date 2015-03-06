require 'test_helper'

class WelcomePageTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
  end

  # user's section and followers tests located in test/integration/user_page_test.rb
  # all articles list when not logged in test located in test/integration/index_articles_test.rb
  # because their code is equal to this page

  test 'welcome page template' do
    get root_path
    assert_response :success
    assert_template 'welcome/index'
    assert_template partial: 'articles/_all_articles'
    assert_template partial: 'shared/_user_info_current', count: 0
    assert_template partial: 'shared/_followers_current', count: 0
    log_in_as(@user)
    assert_redirected_to root_url
    follow_redirect!
    assert_template partial: 'shared/_user_info_current'
    assert_template partial: 'shared/_followers_current'
  end

  test 'user feed when logged in' do
    log_in_as(@user)
    get root_path
    assert_select 'div#art-ajax-paginate' do
      assert_select 'ul.list-unstyled>li.li-zebra' do
        @user.feed.paginate(page: 1).per_page(10).each do |article|
          if article.user == @user
            assert_equal article.user.name, @user.name
            assert_select 'a[title=?][href=?]', "Автор: #{article.user.name}", user_path(@user) do
              assert_select 'img.avatar[src=?]', article.user.avatar.url(:icon)
            end
            assert_select 'a[href=?]', edit_article_path(article), 1
            assert_select 'a[data-method=delete][href=?]', article_path(article), 1
          else
            assert @user.following?(article.user)
            assert_select 'a[title=?][href=?]', "Автор: #{article.user.name}", user_path(article.user) do
              assert_select 'img.avatar[src=?]', article.user.avatar.url(:icon)
            end
            assert_select 'a[href=?]', edit_article_path(article), 0
            assert_select 'a[data-method=delete][href=?]', article_path(article), 0
          end
          assert_select 'span.art-date', (article.updated_at.strftime '%d-%m-%Y в %H:%M')
          assert_select 'a.show-but[href=?]', article_path(article), 1
          assert_select 'a[href=?]', article_path(article), article.title, 1
          assert_match CGI.escapeHTML(article.description.first(10)), response.body
        end
      end
      assert_select 'div.paginator'
    end
  end
end
