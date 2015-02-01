class WelcomeController < ApplicationController
  def index
    if logged_in?
      @articles = current_user.feed.page(params[:articles_page]).per_page(10)
      @followers = current_user.followers.page(params[:followers_page]).per_page(10)
      @following = current_user.following.page(params[:following_page]).per_page(10)
    else
      @articles = Article.all.page(params[:articles_page]).per_page(10)
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
