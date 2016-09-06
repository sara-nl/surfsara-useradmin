# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview
  def invitation
    InviteMailer.invitation('john.doe@example.com', 'eb693ec8252cd630102fd0d0fb7c3485')
  end
end
