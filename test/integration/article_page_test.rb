require 'test_helper'

class ArticlePageTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:second)
    @article = articles(:art2)
    @comment = comments(:comm11)
  end

  test 'article page template' do
    get article_path(@article)
    assert_response :success
    assert_template 'articles/show'
    assert_template partial: 'articles/_navbar_bottom'
    assert_template partial: 'comments/_comm_list'
    assert_template partial: 'comments/_form'
    assert_select 'title', full_title(@article.title)
  end

  test 'article body' do
    get article_path(@article)
    assert_select 'div.article-header' do
      assert_select 'h2', @article.title
      assert_select 'a[href=?]', user_path(@article.user), @article.user.name
      assert_select 'span>strong', (@article.updated_at.strftime '%d-%m-%Y в %H:%M')
    end
    assert_select 'div.t-block', /#{@article.description}\s+#{@article.text}/
    assert_select 'a[href=?]', edit_article_path(@article), 0
    assert_select 'a[data-method=delete][href=?]', article_path(@article), 0
  end

  test 'bottom navbar appearance' do
    get article_path(@article)
    assert_select 'nav.navbar-fixed-bottom' do
      assert_select 'a[href=?]', articles_path, 1
      # prev and next article links with article titles on hover
      a_prev = articles(:art1)
      a_next = articles(:art3)
      assert @article.previous_article == a_prev
      assert @article.next_article == a_next
      assert_select 'a.pull-left[title=?][href=?]', a_prev.title, article_path(a_prev), 1 do
        assert_select 'i.glyphicon-arrow-left'
      end
      assert_select 'a.pull-right[title=?][href=?]', a_next.title, article_path(a_next), 1 do
        assert_select 'i.glyphicon-arrow-right'
      end
    end
  end

  test 'bottom navbar prev and next links for first and last article' do
    newest = articles(:art4)
    a_prev = articles(:art3)
    get article_path(Article.first)
    assert Article.first == newest
    assert newest.previous_article == a_prev
    assert_select 'nav.navbar-fixed-bottom' do
      assert_select 'a.pull-left[title=?][href=?]', a_prev.title, article_path(a_prev), 1
      # showing plug instead of the next link
      assert_select 'a.pull-right>i.glyphicon-arrow-right', 0
      assert_select 'i.pull-right.glyphicon-refresh', 1
    end

    oldest = articles(:second_art1)
    a_next = articles(:second_art2)
    get article_path(Article.last)
    assert Article.last == oldest
    assert oldest.next_article == a_next
    assert_select 'nav.navbar-fixed-bottom' do
      assert_select 'a.pull-right[title=?][href=?]', a_next.title, article_path(a_next), 1
      # showing plug instead of the previous link
      assert_select 'a.pull-left>i.glyphicon-arrow-right', 0
      assert_select 'i.pull-left.glyphicon-refresh', 1
    end
  end

  test 'author see additional edit and delete links at bottom navbar' do
    log_in_as(users(:trend))
    get article_path(@article)
    assert_select 'nav.navbar-fixed-bottom' do
      assert_select 'a[href=?]', edit_article_path(@article), 1
      assert_select 'a[data-method=delete][href=?]', article_path(@article), 1
    end
  end

  test 'comments appearance when not logged in' do
    get article_path(@article)
    assert_match @article.comments.count.to_s, response.body
    assert_select 'div#comm-ajax-paginate' do
      @article.comments.paginate(page: 1).per_page(10).each do |comment|
        assert_select 'span#comm-date', (comment.created_at.strftime '%d-%m-%Y в %H:%M')
        assert_select 'span#comm-username', comment.user.name
        assert_select 'a[data-method=delete][href=?]', article_comment_path(comment.article.id,comment.id), 0
        assert_select 'span#comm-body', comment.body
      end
      assert_select 'div.paginator'
    end
    assert_select 'div#comm_form', 0
    assert_select 'textarea[disabled=disabled][name=?]', 'register_first', 1
    assert_select 'a.btn-main[href=?]', login_path, 1
    assert_select 'a.btn-main[href=?]', signup_path, 1
  end

  test 'comments appearance when logged in, only difference' do
    log_in_as(@user)
    get article_path(@article)
    assert_select 'div#comm-ajax-paginate' do
      @article.comments.paginate(page: 1).per_page(10).each do |comment|
        if comment.user == @user
          assert_select 'a[data-method=delete][href=?]', article_comment_path(comment.article.id, comment.id), 1
        else
          assert_select 'a[data-method=delete][href=?]', article_comment_path(comment.article.id, comment.id), 0
        end
      end
    end
    assert_select 'div#comm_form', 1 do
      assert_select 'form.new_comment', 1
      assert_select 'textarea[name=?]', 'comment[body]', 1
      assert_select 'input.btn[type=submit][name=?]', 'commit', 1
    end
    assert_select 'textarea[disabled=disabled][name=?]', 'register_first', 0
    assert_select 'a.btn-main[href=?]', login_path, 0
    assert_select 'a.btn-main[href=?]', signup_path, 0
  end

  test 'each comment have delete-link-icon when admin' do
    log_in_as(users(:admin))
    get article_path(@article)
    @article.comments.paginate(page: 1).per_page(10).each do |comment|
      assert_select 'a.del-but[data-method=delete][href=?]', article_comment_path(comment.article.id, comment.id), 1
    end
  end

  test 'getting plug instead of list when no comments' do
    get article_path(articles(:art1))
    assert_not articles(:art1).comments.present?
    assert_select 'span#no-comm', 1
  end

  test 'creating - deleting comment' do
    log_in_as(@user)
    get article_path(@article)

    # checking first article's comment (newest first)
    assert_equal @article.comments.first.body, @comment.body
    assert_no_match /Example comment body text/, response.body

    # creating wrong (empty) comment
    assert_no_difference '@article.comments.count' do
      post article_comments_path(@article), comment: { body: '' }
    end
    assert_redirected_to article_path(@article)
    follow_redirect!
    assert_not flash.empty?

    # creating new comment, following redirection
    assert_difference '@article.comments.count', +1 do
      post article_comments_path(@article), comment: { body: 'Example comment body text' }
    end
    assert_redirected_to article_path(@article)
    follow_redirect!
    assert_not flash.empty?

    # ckecking if created comment became first and is shown on article's page
    assert_equal @article.comments.first.body, 'Example comment body text'
    assert_match /Example comment body text/, response.body

    # deleting this comment
    assert_difference '@article.comments.count', -1 do
      delete article_comment_path(@article.id, @article.comments.first.id)
    end
    assert_redirected_to article_path(@article)
    follow_redirect!
    assert flash.empty?

    # checking first comment again
    assert_equal @article.comments.first.body, @comment.body
    assert_no_match /Example comment body text/, response.body
  end

  test 'scroll to top button' do
    get article_path(@article)
    assert_select 'a[href=?]', "#{article_path(@article)}#top" do
      assert_select 'i.glyphicon-arrow-up'
    end
  end
end
