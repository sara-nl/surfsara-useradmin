require 'rails_helper'

describe OneClient, :vcr do
  describe '.users' do
    subject(:users) { OneClient.users }

    it 'retrieves a list of users' do
      expect(users.length).to eq(1)
      expect(users.first.name).to eq('useradmin')
    end
  end

  describe '.find_user' do
    subject(:user) { OneClient.find_user(username) }

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

  describe '.create_user' do
    subject(:create_user) { OneClient.create_user('socrates', 'secret') }

    it 'returns the User after it is created' do
      expect(create_user.name).to eq('socrates')
    end

    it 'fails when a user with a given username already exists' do
      expect { create_user }.to raise_error(/\[UserAllocate\] NAME is already taken by USER/)
    end
  end

  describe '.groups' do
    subject(:groups) { OneClient.groups }

    it 'retrieves a list of groups' do
      expect(groups.length).to eq(1)
      expect(groups.first).to eq(OneClient::Group.new(1, 'users'))
    end
  end
end
