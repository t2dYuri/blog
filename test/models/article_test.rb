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
    @article.text = ' '
    assert_not @article.valid?
  end

  test 'article need description' do
    @article.text = ' '
    assert_not @article.valid?
  end

  test 'article need text' do
    @article.text = ' '
    assert_not @article.valid?
  end

  test 'maximum title length is 100 characters' do
    @article.title = 'a' * 101
    assert_not @article.valid?
  end

  test 'maximum description length is 500 characters' do
    @article.title = 'a' * 501
    assert_not @article.valid?
  end

  test 'articles order should be latest first' do
    assert_equal Article.first, articles(:art4)
  end
end
