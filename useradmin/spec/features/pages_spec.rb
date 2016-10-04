require 'feature_helper'

describe PagesController, :feature do
  context 'given no user is logged in', current_user: :logged_out do
    it 'shows a 404 page' do
      visit root_path
      expect(page).to have_content('You must be logged into SURFconext to view this page')
    end
  end

  describe 'splash page' do
    it 'allows the user to migrate their account' do
      visit splash_path
      expect(page).to have_link('Login to SURFconext')
    end
  end
end
