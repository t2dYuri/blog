class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        # redirect_back_or user
        redirect_back_or root_url
      else
        message  = 'Учетная запись не активирована. '
        message += 'Ссылка с активациией отправлена на Ваш email'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Неверное сочетание email и пароля'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
