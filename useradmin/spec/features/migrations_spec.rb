require 'feature_helper'

describe MigrationsController, :feature do
  let(:current_user) { build(:current_user) }
  let(:one_user) { build(:one_user) }

  before do
    allow_any_instance_of(One::Client).to receive(:find_user).and_return(one_user)
    allow_any_instance_of(One::Client).to receive(:user_by_password).and_return(nil)
    allow_any_instance_of(One::Client).to receive(:migrate_user)
  end

  context 'when accepting the TOS' do
    it 'migrates an existing OpenNebula account' do
      visit '/migrations/new'
      fill_in 'migration[username]', with: 'existing.user'
      fill_in 'migration[password]', with: 'foobar'
      check 'I agree to the terms of service'
      click_on 'Migrate my account'
      expect(page).to have_content(/account has been successfully migrated/)
    end
  end

  context 'when not accepting the TOS' do
    it 'shows an error' do
      visit '/migrations/new'
      click_on 'Migrate my account'
      expect(page).to have_content(/1 error is keeping your HPC Cloud account from being migrated/)
    end
  end
end
