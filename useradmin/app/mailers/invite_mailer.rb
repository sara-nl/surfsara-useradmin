class InviteMailer < ApplicationMailer
  def invitation(model, token)
    @model = model
    @token = token
    mail(
      to: @model.email,
      return_path: @model.created_by,
      reply_to: @model.created_by
    )
  end
end
