require 'feature_helper'

describe MigrationsController, :feature do
  let(:current_user) { build(:current_user) }
  let(:one_user) { build(:one_user) }

  before do
    expect_any_instance_of(One::Client).to receive(:find_user).and_return(one_user)
    expect_any_instance_of(One::Client).to receive(:migrate_user)
  end

  it 'migrates an existing OpenNebula account' do
    visit '/migrations/new'
    fill_in 'reform[username]', with: 'existing.user'
    fill_in 'reform[password]', with: 'foobar'
    check 'I agree to the terms of service'
    click_on 'Migrate my account'
    expect(page).to have_content(/account has been successfully migrated/)
  end
end
