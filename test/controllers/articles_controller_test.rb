require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase

  def setup
    @user = users(:trend)
    @article = articles(:art1)
    @second_user_article = articles(:second_art1)
  end

  test 'articles routes' do
    # articles index if search query = nil
    assert_routing({ path: '/articles', method: :get },
                   { controller: 'articles', action: 'index' })
    # articles index if search query not nil
    assert_routing({ path: '/articles', method: :get },
                   { controller: 'articles', action: 'index', query: '123' }, {}, { query: '123' })
    assert_routing({ path: 'articles/1', method: :get },
                   { controller: 'articles', action: 'show', id: '1' })
    assert_routing({ path: 'articles/new', method: :get },
                   { controller: 'articles', action: 'new' })
    assert_routing({ path: '/articles', method: :post },
                   { controller: 'articles', action: 'create' })
    assert_routing({ path: 'articles/1/edit', method: :get },
                   { controller: 'articles', action: 'edit', id: '1' })
    assert_routing({ path: 'articles/1', method: :patch },
                   { controller: 'articles', action: 'update', id: '1' })
    assert_routing({ path: 'articles/1', method: :delete },
                   { controller: 'articles', action: 'destroy', id: '1' })
  end

  test 'should redirect from creating article when not logged in' do
    get :new
    assert_no_difference 'Article.count' do
      post :create, article: { title: 'Article title',
                               description: 'Article Description',
                               text: 'Article Text' }
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from editing article when not logged in' do
    get :edit, id: @article
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from deleting article when not logged in' do
    assert_no_difference 'Article.count' do
      delete :destroy, id: @article
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from editing article from another user' do
    log_in_as(@user)
    get :edit, id: @second_user_article
    assert_redirected_to root_url
  end

  test 'should redirect from deleting article from another user' do
    log_in_as(@user)
    assert_no_difference 'Article.count' do
      delete :destroy, id: @second_user_article
    end
    assert_redirected_to root_url
  end
end
