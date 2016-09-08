require 'rails_helper'

describe Invite::Create do
  let(:run) { Invite::Create.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }
  let(:email_address) { 'john.doe@example.com' }
  let(:one_user) { OneClient::User.new(1, 'testuser', [10]) }
  let(:one_group) { OneClient::Group.new(10, 'testgroup') }

  before do
    allow(OneClient).to receive(:groups).and_return([one_group])
  end

  context 'with valid input' do
    let(:params) { {invite: {email: email_address, group_id: one_group.id, role: Role.admin}} }

    it 'persists valid input' do
      expect(res).to be_truthy
      expect(op.model.persisted?).to be_truthy
      expect(op.model.email).to eq email_address
      expect(op.model.group_id).to eq one_group.id
      expect(op.model.group_name).to eq one_group.name
    end

    describe 'token' do
      let(:token) { 'eb693ec8252cd630102fd0d0fb7c3485' }
      let(:encrypted_token) { Digest::SHA2.hexdigest(token) }

      it 'stores the encrypted token' do
        expect(SecureRandom).to receive(:hex).and_return(token)
        expect(op.model.token).to eq encrypted_token
      end
    end

    describe 'email' do
      before { run }

      it 'emails an invite to the given email address' do
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq [email_address]
      end
    end
  end

  context 'with invalid input' do
    let(:params) { {invite: {}} }

    it 'rejects invalid input' do
      expect(res).to be_falsey
      expect(op.model.persisted?).to be_falsey
    end
  end
end
