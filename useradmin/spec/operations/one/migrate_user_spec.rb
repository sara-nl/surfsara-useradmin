require 'rails_helper'

describe One::MigrateUser do
  let(:existing_username) { 'Rick' }
  let(:existing_password) { 'NeverGonnaGiveYouUp' }
  let(:current_user) { build(:current_user) }

  let(:params) do
    {
      current_user: current_user,
      migration: {username: existing_username, password: existing_password, accept_terms_of_service: '1'}
    }
  end
  let(:run) do
    One::MigrateUser.run(params)
  end
  let(:res) { run.first }
  let(:op) { run.last }

  let(:user_client) { double('User client') }
  let(:admin_client) { double('Admin client') }

  before do
    expect(One::Client)
      .to receive(:new).with(credentials: "#{existing_username}:#{existing_password}").and_return(user_client)
  end

  context 'with correct credentials' do
    before do
      expect(One::Client)
        .to receive(:new).with(no_args).and_return(admin_client)

      expect(user_client)
        .to receive(:find_user).with(existing_username).and_return(build(:one_user, id: 123, name: existing_username))
    end

    context 'and a SURFconext account that is already linked to an OpenNebula account' do
      before do
        expect(admin_client)
          .to receive(:user_by_password).with(current_user.remote_user).and_return(build(:one_user))
      end

      it 'fails' do
        expect(res).to be_falsey
        expect(op.errors).to be_added(:base, :account_already_linked)
      end
    end

    context 'and a SURFconext account that is not yet linked to an OpenNebula account' do
      before do
        expect(admin_client).to receive(:user_by_password).with(current_user.remote_user).and_return(nil)
        expect(admin_client).to receive(:migrate_user).with(123, current_user.remote_user)
      end

      it 'migrates the user to the new authentication scheme' do
        run
        migration = Migration.last
        expect(migration.one_username).to eq(existing_username)
        expect(migration.accepted_by).to eq(current_user.remote_user)
        expect(migration.accepted_from_ip).to eq(current_user.remote_ip)
      end
    end
  end

  context 'with incorrect credentials' do
    let(:existing_password) { 'faultyPassword' }

    before do
      expect(user_client)
        .to receive(:find_user)
        .with(existing_username)
        .and_raise(RuntimeError, "[UserPoolInfo] User couldn't be authenticated, aborting call.")
    end

    it 'shows an authentication failure' do
      expect(res).to be_falsey
      expect(op.errors).to be_added(:base, :could_not_be_authenticated)
    end
  end
end
