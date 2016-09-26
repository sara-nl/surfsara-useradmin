# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview
  def invitation
    invite = Invite.new(email: 'john.doe@example.com', group_name: 'testgroup', role: Role.group_admin)
    InviteMailer.invitation(invite, 'eb693ec8252cd630102fd0d0fb7c3485')
  end
end
