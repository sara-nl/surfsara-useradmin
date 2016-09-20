require 'rails_helper'

describe Invite::Accept do
  let(:run) { Invite::Accept.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }

  let(:token)  { 'secret' }
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
    let(:one_user) { double(id: 15, group_ids: []) }

    context 'given the user does not have an account in OpenNebula' do
      before do
        expect(OneClient).to receive(:find_user).with(current_user.one_username)
        expect(OneClient).to receive(:create_user)
          .with(current_user.one_username, current_user.one_password)
          .and_return(one_user)
        expect(OneClient).to receive(:add_user_to_group).with(one_user.id, invite.group_id)
      end

      it 'accepts the invite, creates a user and adds it to the group it was invited for' do
        expect(res).to be_truthy
        expect(op.model.accepted_at).to eq accepted_at
        expect(op.model.accepted_by).to eq current_user.uid
      end
    end

    context 'given the user already has an account in OpenNebula' do
      it 'adds the user to the group it was invited for' do
        expect(OneClient).to receive(:find_user).with(current_user.one_username).and_return(one_user)
        expect(OneClient).to receive(:add_user_to_group).with(one_user.id, invite.group_id)
        run
      end

      context 'and the user is already in the group it was invited for' do
        let(:one_user) { double(id: 15, group_ids: [group_id]) }

        it 'does not add the user to the group again' do
          expect(OneClient).to receive(:find_user).with(current_user.one_username).and_return(one_user)
          run
        end
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
