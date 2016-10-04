require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do
  before do
    allow_any_instance_of(One::Client).to receive(:groups).and_return(build_list(:one_group, 1))
  end

  describe 'invite' do
    let(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: build(:current_user)
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
      expect(mail.from).to eq(['noreply@surfsara.nl'])
      expect(mail.return_path).to eq('isaac@university-example.org')
      expect(mail.reply_to).to eq(['isaac@university-example.org'])
    end

    it 'contains the activation link' do
      expect(mail.body.encoded)
        .to include(verify_invite_url(token))
    end
  end
end
