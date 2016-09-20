require 'rails_helper'

describe Invite::Accept do
  let(:run) { Invite::Accept.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }

  let(:token)  { 'secret' }
  before { allow(InviteToken).to receive(:random).and_return(InviteToken.new(token)) }
  let!(:invite) { Invite::Create.(invite: {email: 'john.doe@example.com', group_id: 1, role: Role.admin}).model }
  let(:current_user) { double(uid: 'bob') }

  context 'with TOS accepted' do
    let(:params) do
      {id: token, invite: {accept_terms_of_service: '1'}, current_user: current_user}
    end

    let(:accepted_at) { Time.parse '2016-09-20T10:50:00' }
    before { Timecop.freeze accepted_at }

    it 'accepts the invite' do
      expect(res).to be_truthy
      expect(op.model.accepted_at).to eq accepted_at
      expect(op.model.accepted_by).to eq current_user.uid
    end
  end

  context 'with TOS not accepted' do
    let(:params) do
      {id: token, invite: {accept_terms_of_service: '0'}, current_user: current_user}
    end

    it 'rejects the acceptance of the invite' do
      expect(res).to be_falsey
      expect(op.model.accepted_at).to be_nil
      expect(op.model.accepted_by).to be_nil
    end
  end
end
