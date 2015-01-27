class WelcomeController < ApplicationController
  def index
    if logged_in?
      # @feed_items = current_user.feed.paginate(page: params[:page], :per_page => 10)
    end
    @articles = Article.all.paginate(page: params[:page], :per_page => 10)
  end

  def help
  end

  def about
  end

  def contact
  end
end
