class InviteMailer < ApplicationMailer
  def invitation(email)
    mail(to: email) do |format|
      format.html
      format.text
    end
  end
end
