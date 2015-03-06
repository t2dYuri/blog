require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @user = users(:trend)
    @article = @user.articles.build(title: 'Lorem ipsun', description: 'Lorem ipsum', text: 'Lorem ipsum')
  end

  test 'should be valid' do
    assert @article.valid?
  end

  test 'article need user id' do
    @article.user_id = nil
    assert_not @article.valid?
  end

  test 'article need title' do
    @article.title = ' '
    assert_not @article.valid?
  end

  test 'article need description' do
    @article.description = ' '
    assert_not @article.valid?
  end

  test 'article need text' do
    @article.text = ' '
    assert_not @article.valid?
  end

  test 'maximum title length is 100 characters' do
    @article.title = 'a' * 81
    assert_not @article.valid?
  end

  test 'maximum description length is 500 characters' do
    @article.description = 'a' * 501
    assert_not @article.valid?
  end

  test 'articles order should be latest first' do
    assert_equal Article.first, articles(:art4)
  end

  test "deleting article must destroy article's comments" do
    @article.save
    @article.comments.create!(body: 'Example comment', user_id: @user.id)
    assert_difference 'Comment.count', -1 do
      @article.destroy
    end
  end
end
