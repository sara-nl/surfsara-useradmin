class InviteMailer < ApplicationMailer
  def invitation(email, token, group)
    @token = token
    @group = group
    mail(to: email)
  end
end
