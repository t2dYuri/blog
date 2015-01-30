class WelcomeController < ApplicationController
  def index
    if logged_in?
      # @feed_items = current_user.feed.paginate(page: params[:page], :per_page => 10)
      @followers = current_user.followers.page(params[:followers_page]).per_page(10)
      @following = current_user.following.page(params[:following_page]).per_page(10)
    end
    @articles = Article.all.page(params[:page]).per_page(10)
  end

  def help
  end

  def about
  end

  def contact
  end
end
