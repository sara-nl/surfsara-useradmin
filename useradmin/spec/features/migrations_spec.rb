require 'feature_helper'

describe MigrationsController, :feature do
  let(:current_user) { build(:current_user) }

  it 'migrates an existing OpenNebula account' do
    visit '/migrations/new'
    expect(page).to include /Log in to HPC cloud to migrate/
    fill_in 'Username', with: 'existing.user'
    fill_in 'Password', with: 'foobar'
    check 'I agree to the terms of service'
    click_on 'Migrate my account'
    expect(page).to include /Your account has been migrated/
    expect(page).to include /Visit OpenNebula/
  end
end
