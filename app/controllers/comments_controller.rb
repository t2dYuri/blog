class CommentsController < ApplicationController

  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_to article_path(@article) }
        format.js { redirect_to article_path(@article) }
      end
      flash[:info] = 'Спасибо за Ваш комментарий'
    else
      redirect_to article_path(@article)
      flash[:warning] = 'Плохой комментарий'
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def correct_user
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @user = current_user == @comment.user || current_user.admin?
    redirect_to root_url unless @user
  end
end
