require 'rails_helper'

describe Invite::Accept do
  before do
    allow_any_instance_of(One::Client).to receive(:groups).and_return(build_list(:one_group, 1))
  end

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
  let(:current_user) { build(:current_user) }

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
      expect(op.model.accepted_by).to eq current_user.remote_user
      expect(op.model.accepted_from_ip).to eq current_user.remote_ip
    end

    context 'given the invite has already been accepted' do
      before { Invite::Accept.run(params) }

      it 'rejects the acceptance of the invite' do
        expect(res).to be_falsey
      end
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
