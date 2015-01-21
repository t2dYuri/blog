class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = 'Учетная запись активирована'
      redirect_to user
    else
      flash[:danger] = 'Неверная ссылка активации'
      redirect_to root_url
    end
  end
end
