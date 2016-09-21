require 'rails_helper'

describe Invite::Accept do
  let(:run) { Invite::Accept.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }

  let(:token) { 'secret' }
  before { allow(InviteToken).to receive(:random).and_return(InviteToken.new(token)) }
  let(:group_id) { 1 }
  let!(:invite) do
    Invite::Create.(
      current_user: current_user,
      invite: {email: 'john.doe@example.com', group_id: group_id, group_name: 'Users', role: Role.member}
    ).model
  end
  let(:current_user) do
    double(
      uid: 'isaac',
      one_username: 'university-example.org-isaac',
      one_password: '3d21c8a6d89e3332e3d388852f99d5e5ce114ff9',
      admin_groups: []
    )
  end

  context 'with TOS accepted' do
    let(:params) do
      {id: token, invite: {accept_terms_of_service: '1'}, current_user: current_user}
    end

    let(:accepted_at) { Time.parse '2016-09-20T10:50:00' }
    before { Timecop.freeze accepted_at }

    before { expect(One::CreateUser).to receive(:call).with(current_user: current_user, invite: invite) }

    it 'accepts the invite' do
      expect(res).to be_truthy
      expect(op.model.accepted_at).to eq accepted_at
      expect(op.model.accepted_by).to eq current_user.one_username
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
