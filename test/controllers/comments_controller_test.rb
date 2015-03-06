require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  def setup
    @user = users(:trend)
    @article = articles(:art2)
    @comment = comments(:comm10)
  end

  test 'should redirect from creating comment when not logged in' do
    assert_no_difference 'Comment.count' do
      post :create, article_id: @article, comment: { body: 'Example comment' }
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from deleting comment when not logged in' do
    assert_no_difference 'Comment.count' do
      delete :destroy, article_id: @article, id: @comment
    end
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test 'should redirect from deleting comment from another user' do
    log_in_as(@user)
    assert_no_difference 'Comment.count' do
      delete :destroy, article_id: @article, id: @comment
    end
    assert_redirected_to root_url
  end

  test 'should not create blank comment' do
    log_in_as(@user)
    assert_no_difference 'Comment.count' do
      post :create, article_id: @article, comment: { body: '' }
    end
    assert_redirected_to article_path(@article)
    assert_not flash.empty?
  end

  test 'should create comment when logged in' do
    log_in_as(@user)
    assert_difference 'Comment.count', +1 do
      post :create, article_id: @article, comment: { body: 'Example comment' }
    end
    assert_redirected_to article_path(@article)
    assert_not flash.empty?
  end

  test 'should delete comment with right user' do
    log_in_as(users(:second))
    assert_difference 'Comment.count', -1 do
      delete :destroy, article_id:@article, id: @comment
    end
    assert_redirected_to article_path(@article)
  end
end
