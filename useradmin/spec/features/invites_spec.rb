require 'feature_helper'

describe InvitesController, :feature do
  let!(:invite) { Invite::Create.(invite: {email: 'foo@bar.com', group_id: 1, role: Role.admin}).model }

  it "lists invites" do
    visit '/invites'
    expect(page).to have_content 'foo@bar.com'
  end

  it "creates invites" do
    visit '/invites'
    click_on 'New invite'

    expect(page).to have_content 'New invite'

    fill_in 'Email address', with: 'user@example.com'
    select 'users', from: 'Group'
    select 'admin', from: 'Role'

    click_on 'Submit'

    expect(page).to have_current_path(invite_path(Invite.last.id))
    expect(page).to have_content 'Invite - user@example.com'
  end
end
