class InviteMailer < ApplicationMailer
  def invitation(model, raw_token, sender)
    @model = model
    @token = raw_token
    mail from: sender, to: @model.email
  end
end
