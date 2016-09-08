require 'feature_helper'

describe InvitesController do
  let(:invite) { Invite::Create.(invite: {email: 'foo@bar.com'}).model }

  xit "manages invites" do
    visit '/invites'
    expect(page).to have_content 'foo@bar.com'
  end
end
