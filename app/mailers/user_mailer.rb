class UserMailer < ApplicationMailer
  default from: 'noreply@yurik-blogg.com'

  def account_activation(user)
    @user = user
    mail to: user.email, subject: 'Активация учетной записи'
  end

  def password_reset
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
