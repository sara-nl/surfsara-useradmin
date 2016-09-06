class InviteMailer < ApplicationMailer
  def invitation(email, token)
    @token = token
    mail(to: email, token: 'foo')
  end
end
