require "spec_helper"
require_relative "../../app/lib/one_client"

describe OneClient, :integration do
  describe '.users' do
    subject(:users) { OneClient.users }

    it 'retrieves a list of users' do
      expect(users.length).to eq(1)
      expect(users.first).to eq(OneClient::User.new(4, 'useradmin', [1]))
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
