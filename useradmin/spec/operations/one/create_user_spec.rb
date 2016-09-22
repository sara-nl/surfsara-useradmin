require 'rails_helper'

describe One::CreateUser do
  let(:run) { One::CreateUser.run(current_user: current_user, invite: invite) }
  let(:res) { run.first }
  let(:op) { run.last }

  let(:current_user) { build(:current_user) }
  let(:group_id) { 1 }
  let(:token) { 'secret' }
  before { allow(InviteToken).to receive(:random).and_return(InviteToken.new(token)) }
  let!(:invite) do
    Invite::Create.(
      current_user: current_user,
      invite: {email: 'john.doe@example.com', group_id: group_id, group_name: 'Users', role: role}
    ).model
  end
  let(:role) { Role.member }
  let(:one_user) { build(:one_user, :no_group_memberships) }

  context 'given the user does not have an account in OpenNebula' do
    before do
      expect(One::Client).to receive(:find_user).with(current_user.one_username)
      expect(One::Client).to receive(:create_user)
        .with(current_user.one_username, current_user.one_password)
        .and_return(one_user)
      expect(One::Client).to receive(:add_user_to_group).with(one_user.id, invite.group_id)
    end

    it 'creates a user and adds it to the group it was invited for' do
      run
    end

    context 'and the user is invited to become a group admin' do
      let(:role) { Role.group_admin }

      before do
        expect(One::Client).to receive(:user_admin_of_group?).with(one_user.id, invite.group_id).and_return(false)
        expect(One::Client).to receive(:make_user_group_admin).with(one_user.id, invite.group_id)
      end

      it 'adds the user as a group admin' do
        run
      end
    end

    context 'and the user already is an admin of the group' do
      let(:role) { Role.group_admin }

      before do
        expect(One::Client).to receive(:user_admin_of_group?).with(one_user.id, invite.group_id).and_return(true)
      end

      it 'does not add the user as a group admin again' do
        run
      end
    end
  end

  context 'given the user already has an account in OpenNebula' do
    it 'adds the user to the group it was invited for' do
      expect(One::Client).to receive(:find_user).with(current_user.one_username).and_return(one_user)
      expect(One::Client).to receive(:add_user_to_group).with(one_user.id, invite.group_id)
      run
    end

    context 'and the user is already in the group it was invited for' do
      let(:one_user) { build(:one_user, group_ids: [group_id]) }

      it 'does not add the user to the group again' do
        expect(One::Client).to receive(:find_user).with(current_user.one_username).and_return(one_user)
        run
      end
    end
  end
end
