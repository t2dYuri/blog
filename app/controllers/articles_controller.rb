class ArticlesController < ApplicationController
  # http_basic_authenticate_with name: "trend", password: "polik", except: [:index, :show]
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  def index
    @articles = Article.search(params[:query]).page(params[:page]).per_page(10)
  end

  def show
    @article = Article.find(params[:id])
    @comments = @article.comments.page(params[:page]).per_page(10)
  end

  def new
    @article = Article.new
  end

  def edit
    @article = Article.find(params[:id])
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to @article
    else
      render 'new'
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to request.referrer || root_url
  end

  private

  def article_params
    params.require(:article).permit(:title, :text, :description, :user_id)
  end

  def correct_user
    @article = current_user.articles.find_by(id: params[:id]) || current_user.admin?
    # redirect_to root_url if @article.nil?
    redirect_to root_url unless @article
  end
end
