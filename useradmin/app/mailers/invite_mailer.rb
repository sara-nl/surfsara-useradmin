class InviteMailer < ApplicationMailer
  def invitation(model, token)
    @model = model
    @token = token
    mail(to: @model.email)
  end
end
