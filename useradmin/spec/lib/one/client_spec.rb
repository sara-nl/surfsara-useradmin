require 'rails_helper'

describe One::Client, :vcr do
  let(:one_client) { One::Client.new }

  describe '#users' do
    subject(:users) { one_client.users }

    it 'retrieves a list of users' do
      expect(users.length).to eq(1)
      expect(users.first.name).to eq('useradmin')
    end
  end

  describe '#find_user' do
    subject(:user) { one_client.find_user(username) }

    context 'given a known username' do
      let(:username) { 'useradmin' }

      it 'returns a User' do
        expect(user.id).to eq(4)
        expect(user.name).to eq('useradmin')
        expect(user.group_ids).to eq([1])
      end
    end

    context 'given an unknown username' do
      let(:username) { 'unknown' }

      it 'returns nil' do
        expect(user).to be_nil
      end
    end
  end

  describe '#user_by_password' do
    subject(:user) { one_client.user_by_password(password) }

    context 'given a known password' do
      let(:password) { 'admin' }

      it 'returns a User' do
        expect(user.id).to eq(2)
        expect(user.name).to eq('admin')
        expect(user.group_ids).to eq([0, 1])
      end
    end

    context 'given an unknown password' do
      let(:password) { 'unknown' }

      it 'returns nil' do
        expect(user).to be_nil
      end
    end
  end

  describe '#groups_for_admin' do
    subject { one_client.groups_for_admin(2) }

    it 'returns a list of groups' do
      expect(subject).to eq([One::Group.new(1, 'users')])
    end
  end

  describe '#create_user' do
    subject(:create_user) { one_client.create_user('socrates', 'secret') }

    it 'returns the User after it is created' do
      expect(create_user.name).to eq('socrates')
    end

    it 'fails when a user with a given username already exists' do
      expect { create_user }.to raise_error(/\[UserAllocate\] NAME is already taken by USER/)
    end
  end

  describe '#add_user_to_group' do
    subject(:add_user_to_group) { one_client.add_user_to_group(10, 0) }

    it 'returns nil' do
      expect(add_user_to_group).to be_nil
    end

    it 'fails when a user is already in that group' do
      expect { add_user_to_group }.to raise_error(/\[UserAddGroup\] User is already in this group/)
    end
  end

  describe '#groups' do
    subject(:groups) { one_client.groups }

    it 'retrieves a list of groups' do
      expect(groups.length).to eq(1)
      expect(groups.first).to eq(One::Group.new(1, 'users'))
    end
  end

  describe '#make_user_group_admin' do
    subject(:make_user_group_admin) { one_client.make_user_group_admin(10, 1) }

    it 'returns nil' do
      expect(make_user_group_admin).to be_nil
    end

    it 'fails when a user is already admin of that group' do
      expect { make_user_group_admin }
        .to raise_error(/\[GroupAddAdmin\] Cannot edit group\. User 10 is already an administrator of Group 1/)
    end
  end

  describe '#user_admin_of_group?' do
    subject(:is_user_admin_of_group) { one_client.user_admin_of_group?(user_id, group_id) }

    context 'when the user is an admin of the group' do
      let(:user_id) { 10 }
      let(:group_id) { 1 }

      it 'returns true' do
        expect(is_user_admin_of_group).to be_truthy
      end
    end

    context 'when the user is not an admin of the group' do
      let(:user_id) { 9 }
      let(:group_id) { 1 }

      it 'returns false' do
        expect(is_user_admin_of_group).to be_falsey
      end
    end
  end
end
