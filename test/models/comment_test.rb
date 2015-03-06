require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  def setup
    @article = articles(:art2)
    @comment = articles(:art1).comments.create(body: 'Example comment', user_id: users(:trend).id)
  end

  test 'should be valid' do
    assert @comment.valid?
  end

  test 'comment user_id cannot be nil' do
    @comment.user_id = nil
    assert_not @comment.valid?
  end

  test 'comment body cannot be blank' do
    @comment.body = ' '
    assert_not @comment.valid?
  end

  test 'maximum comment body length is 500 characters' do
    @comment.body = 'a' * 501
    assert_not @comment.valid?
  end

  test 'comments order should be latest first' do
    assert_equal @article.comments.first, comments(:comm11)
    assert_equal @article.comments.last, comments(:comm1)
  end
end
