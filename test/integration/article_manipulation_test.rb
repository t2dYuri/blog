require 'test_helper'

class ArticleManipulationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:trend)
    @article = articles(:art1)
  end

  test 'create/edit article form' do
    log_in_as(@user)
    get new_article_path
    assert_response :success
    assert_template 'articles/new', partial: 'articles/_form'
    assert_select 'form.new_article' do
      assert_select 'label', 3
      assert_select 'input[type=text][name=?]', 'article[title]', 1
      assert_select 'textarea[name=?]', 'article[description]', 1
      assert_select 'textarea.tinymce[name=?]', 'article[text]', 1
      assert_select 'input[type=submit][name=?]', 'commit', 1
      assert_select 'a.btn[href=?]', articles_path
    end
  end

  test 'creating article' do
    log_in_as(@user)
    get new_article_path
    assert_difference 'Article.count', +1 do
      post articles_path, article: { title: 'Art Title',
                                     description: 'Art Description',
                                     text: 'Art Text' }
    end
    assert_response :redirect
    assert_redirected_to article_path(assigns(:article))
    follow_redirect!
    assert_response :success
    assert_template 'articles/show'
    assert_select 'div.article-header>h2', 'Art Title'
    assert_match /Art Description/, response.body
    assert_match /Art Text/, response.body
  end

  test 'should not create article with wrong params' do
    log_in_as(@user)
    get new_article_path
    assert_no_difference 'Article.count' do
      post articles_path, article: { title: '', description: '', text: '' }
    end
    assert_template 'articles/new'
    assert_select 'div#error_explanation' do
      assert_select 'div.alert'
    end
    assert_select 'div.field_with_errors' do
      assert_select 'input[type=text][name=?][value=?]', 'article[title]', '', 1
      assert_select 'textarea.form-control[name=?]', 'article[description]', 1
      assert_select 'textarea.tinymce[name=?]', 'article[text]', 1
    end
  end

  test 'successful editing article' do
    log_in_as(@user)
    get article_path(@article)
    assert_select 'title', full_title(@article.title)
    get edit_article_path(@article)
    assert_template 'articles/edit', partial: 'articles/_form'
    patch article_path(@article), article: { title: 'New Title',
                                             description: 'New Description',
                                             text: 'New Text' }
    assert_redirected_to article_path(@article)
    follow_redirect!
    assert_template 'articles/show'
    assert_select 'title', full_title('New Title')
    assert_select 'div.article-header>h2', 'New Title'
    assert_match /New Description/, response.body
    assert_match /New Text/, response.body
  end

  test 'successful deleting article' do
    log_in_as(@user)
    get article_path(@article)
    assert_difference 'Article.count', -1 do
      delete article_path(@article)
    end
    assert_redirected_to root_url
    assert flash.empty?
  end
end
