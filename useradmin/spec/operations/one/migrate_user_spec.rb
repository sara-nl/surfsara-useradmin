require 'rails_helper'

describe One::MigrateUser do
  let(:existing_username) { 'Rick' }
  let(:existing_password) { 'NeverGonnaGiveYouUp' }
  let(:current_user) { build(:current_user) }

  let(:params) do
    {
      current_user: current_user,
      reform: {username: existing_username, password: existing_password, accept_terms_of_service: '1'}
    }
  end
  let(:run) do
    One::MigrateUser.run(params)
  end
  let(:res) { run.first }
  let(:op) { run.last }

  let(:client) { double }


  context 'with correct credentials' do
    before do
      expect(One::Client)
        .to receive(:new).with(credentials: "#{existing_username}:#{existing_password}").and_return(client)

      expect(client).to receive(:find_user).with(existing_username).and_return(build(:one_user, id: 123))
      expect(client).to receive(:migrate_user).with(123, current_user.one_password)
    end

    it 'migrates the user to the new authentication scheme' do
      run
    end
  end

  context 'with incorrect credentials' do
    let(:existing_password) { 'faultyPassword' }

    before do
      expect(One::Client)
        .to receive(:new).with(credentials: "#{existing_username}:#{existing_password}").and_return(client)

      expect(client)
        .to receive(:find_user)
        .with(existing_username)
        .and_raise(RuntimeError, "[UserPoolInfo] User couldn't be authenticated, aborting call.")
    end

    it 'shows an authentication failure' do
      expect(res).to be_falsey
      expect(op.errors).to be_added(:base, :could_not_be_authenticated)
    end
  end

  context 'with an already migrated user'
end
