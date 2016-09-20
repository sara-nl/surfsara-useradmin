require "rails_helper"

RSpec.describe InviteMailer, :vcr, type: :mailer do
  describe 'invite' do
    let(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: double(admin_groups: [double(id: 1, name: 'foo')])
      ).model
    end
    let(:token) { '123abc' }
    let(:mail) { InviteMailer.invitation(invite, token).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Invitation')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['useradmin@surfsara.nl'])
    end

    it 'contains the activation link' do
      expect(mail.body.encoded)
        .to include(verify_invite_url(token))
    end
  end
end
