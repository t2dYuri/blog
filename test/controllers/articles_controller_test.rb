require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase

  def setup
    @user = users(:trend)
    @article = articles(:art1)
    @second_user_article = articles(:second_art1)
  end

  test 'should redirect from creating article when not logged in' do
    get :new
    assert_no_difference 'Article.count' do
      post :create, article: { title: 'Article title', description: 'Article Description', text: 'Article Text' }
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
