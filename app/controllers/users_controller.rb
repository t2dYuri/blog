class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.where(activated: true).page(params[:users_page]).per_page(15)
    @articles = Article.page(params[:articles_page]).per_page(10)
  end

  def show
    @user = User.find(params[:id])
    @articles = @user.articles.page(params[:articles_page]).per_page(10)
    @followers = @user.followers.page(params[:followers_page]).per_page(10)
    @following = @user.following.page(params[:following_page]).per_page(10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(initial_user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Проверьте Ваш email для активации учетной записи. Доставка письма может занять некоторое время'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Профиль успешно обновлен'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.admin?
      redirect_to root_url
    else
      @user.destroy
      flash[:success] = 'Пользователь удален'
      redirect_to users_url
    end
  end

  private

  def initial_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_params
    if current_user && current_user.admin?
      params.require(:user).permit(:name, :email, :password, :password_confirmation,
                                   :about_me, :birth_date, :avatar, :avatar_cache, :remote_avatar_url, :remove_avatar)
    else
      params.require(:user).permit(:name, :password, :password_confirmation,
                                   :about_me, :birth_date, :avatar, :avatar_cache, :remote_avatar_url, :remove_avatar)
    end
  end

  # Before filters
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user) || current_user.admin?
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
