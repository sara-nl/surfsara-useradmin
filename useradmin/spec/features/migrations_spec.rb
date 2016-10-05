require 'feature_helper'

describe MigrationsController, :feature do
  let(:current_user) { build(:current_user) }
  let(:one_user) { build(:one_user) }

  before do
    allow_any_instance_of(One::Client).to receive(:find_user).and_return(one_user)
    allow_any_instance_of(One::Client).to receive(:user_by_password).and_return(nil)
    allow_any_instance_of(One::Client).to receive(:migrate_user)
    allow_any_instance_of(One::Client).to receive(:groups).and_return(build_list(:one_group, 1))
  end

  describe 'create' do
    context 'when accepting the TOS' do
      it 'migrates an existing OpenNebula account' do
        visit '/migrations/new'
        fill_in 'migration[username]', with: 'existing.user'
        fill_in 'migration[password]', with: 'foobar'
        check 'I have read and agree to the terms of service'
        click_on 'Migrate my account'
        expect(page).to have_content(/account has been successfully migrated/)
      end
    end

    context 'when not accepting the TOS' do
      it 'shows an error' do
        visit '/migrations/new'
        click_on 'Migrate my account'
        expect(page).to have_content(/3 errors are keeping your HPC Cloud account from being migrated/)
      end
    end
  end

  describe 'index' do
    before { create(:migration, accepted_at: Time.zone.parse('2016-09-27T15:29:00')) }

    context 'given the current user is a SURFsara admin' do
      it 'lists all migrations' do
        visit '/migrations'
        expect(page).to have_content(['isaac', 'isaac@university-example.org', 'September 27, 2016 15:29'].join(''))
      end
    end

    context 'given the current user it not a SURFsara admin', current_user: :member do
      it 'denies access' do
        visit '/migrations'
        expect(page).to have_content('You are not authorized')
        within('.nav') { expect(page).to have_no_content('Migrations') }
      end
    end
  end
end
