require 'rails_helper'

describe Invite::Create do
  let(:run) { Invite::Create.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }
  let(:email_address) { 'john.doe@example.com' }
  let(:one_user) { One::User.new(1, 'testuser', [10]) }
  let(:one_group) { One::Group.new(10, 'users') }
  let(:current_user) { build(:current_user) }

  before do
    allow_any_instance_of(One::Client).to receive(:groups).and_return([one_group])
  end

  context 'with valid input' do
    let(:params) do
      {
        invite: {email: email_address, group_id: one_group.id, group_name: 'users', role: Role.group_admin},
        current_user: current_user
      }
    end

    it 'persists valid input' do
      expect(res).to be_truthy
      expect(op.model.persisted?).to be_truthy
      expect(op.model.email).to eq email_address
      expect(op.model.group_id).to eq one_group.id
      expect(op.model.group_name).to eq one_group.name
      expect(op.model.created_by).to eq current_user.one_username
    end

    describe 'token' do
      let(:token) { 'eb693ec8252cd630102fd0d0fb7c3485' }
      let(:hashed_token) { Digest::SHA2.hexdigest(token) }

      it 'stores the hashed token' do
        expect(SecureRandom).to receive(:hex).and_return(token)
        expect(op.model.token).to eq hashed_token
      end
    end

    describe 'email' do
      it 'sends an invite' do
        expect(InviteMailer).to receive(:invitation).and_call_original
        run
      end
    end
  end

  context 'with duplicate input' do
    before { Invite::Create.(params) }

    let(:ignore_email_duplicity) { '0' }
    let(:params) do
      {
        invite: {
          email: email_address,
          group_id: one_group.id,
          group_name: 'users',
          role: Role.group_admin,
          ignore_email_duplicity: ignore_email_duplicity
        },
        current_user: current_user
      }
    end

    it 'shows a duplicity warning' do
      expect(res).to be_falsey

      expect(op.contract.errors.full_messages)
        .to include(/One or more invites are already pending\/accepted for this email\, group \& role/)
    end

    context 'when ignoring the duplicity warning' do
      let(:ignore_email_duplicity) { '1' }

      it 'sends the invite anyway' do
        expect(res).to be_truthy
      end
    end
  end

  context 'with invalid input' do
    let(:params) { {invite: {}, current_user: current_user} }

    it 'rejects invalid input' do
      expect(res).to be_falsey
      expect(op.model.persisted?).to be_falsey
    end
  end
end
