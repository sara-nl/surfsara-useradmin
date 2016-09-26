require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do
  describe 'invite' do
    let(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: build(:current_user)
      ).model
    end
    let(:token) { '123abc' }
    let(:sender) { 'Bob Forma <bforma@zilverline.com>' }
    let(:mail) { InviteMailer.invitation(invite, token, sender).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Invitation')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.email])
    end

    it 'renders the sender email' do
      expect(mail['From'].to_s).to eq(sender)
    end

    it 'contains the activation link' do
      expect(mail.body.encoded)
        .to include(verify_invite_url(token))
    end
  end
end
