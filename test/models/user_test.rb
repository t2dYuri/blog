require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: 'Example User',
                     email: 'user@example.com',
                     password: 'foobar',
                     password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '     '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 41
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = 'a' * 49 + '@example.com'
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    wrong_case_email = 'Foo@ExAMPle.CoM'
    @user.email = wrong_case_email
    @user.save
    assert_equal wrong_case_email.downcase, @user.reload.email
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'about_me should not be too long' do
    @user.about_me = 'a' * 201
    assert_not @user.valid?
  end

  test 'authenticated? should be false without digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test "deleting user must destroy user's articles" do
    @user.save
    @user.articles.create!(title: 'Lorem ipsun', description: 'Lorem ipsum', text: 'Lorem ipsum')
    assert_difference 'Article.count', -1 do
      @user.destroy
    end
  end

  test "deleting user must destroy user's comments" do
    @user.save
    @user.comments.create!(body: 'Example comment')
    assert_difference 'Comment.count', -1 do
      @user.destroy
    end
  end

  test 'user should follow and unfollow another user' do
    user1 = users(:trend)
    user2  = users(:second)
    assert_not user1.following?(user2)
    user1.follow(user2)
    assert user1.following?(user2)
    assert user2.followers.include?(user1)
    user1.unfollow(user2)
    assert_not user1.following?(user2)
  end

  test 'feed should include only articles from self and following users' do
    trend = users(:trend)
    second = users(:second)
    third = users(:third)
    # Articles from followed user
    third.articles.each do |article_following|
      assert trend.feed.include?(article_following)
    end
    # Articles from self
    trend.articles.each do |article_self|
      assert trend.feed.include?(article_self)
    end
    # Articles from unfollowed user
    second.articles.each do |article_unfollowed|
      assert_not trend.feed.include?(article_unfollowed)
    end
  end
end
