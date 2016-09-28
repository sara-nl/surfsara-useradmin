require 'feature_helper'

describe ApplicationController, :feature do
  context 'given no user is logged in', current_user: :logged_out do
    it 'shows a 404 page' do
      visit root_path
      expect(page).to have_content('You must be logged into SURFconext to view this page')
    end
  end
end
