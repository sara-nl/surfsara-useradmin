require 'feature_helper'

describe InvitesController, :feature do
  let(:one_user) { build(:one_user) }
  before { allow(One::Client).to receive(:user_by_password).and_return(one_user) }
  let(:groups) { [double(id: 1, name: 'users')] }
  before { allow(One::Client).to receive(:groups).and_return(groups) }

  context 'invite' do
    let!(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: double(admin_groups: groups)
      ).model
    end

    it 'lists invites' do
      visit '/invites'
      expect(page).to have_content 'foo@bar.com'
    end

    it 'creates invites' do
      visit '/invites'
      click_on 'New invite'

      expect(page).to have_content 'New invite'

      click_on 'Send invitation'

      expect(page).to have_content('6 errors prohibited this invite from being saved:')

      fill_in 'Email address', with: 'user@example.com'
      select 'users', from: 'Group'
      select 'Group Administrator', from: 'Role'

      click_on 'Send invitation'

      expect(page).to have_current_path(invite_path(Invite.last.id))
      expect(page).to have_content 'Invite - user@example.com'
    end
  end

  context 'accept' do
    before { allow(InviteToken).to receive(:random).and_return(InviteToken.new(token)) }
    let(:token) { 'invite_token' }
    let!(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: double(admin_groups: [double(id: 1, name: 'foo')])
      ).model
    end

    before { expect(One::CreateUser).to receive(:call) }

    it 'accepts invites' do
      visit verify_invite_path(token)

      expect(page).to have_content 'Accept your invitation'

      click_on 'Accept'

      expect(page).to have_content 'Accept terms of service is required'

      check 'I accept the terms of service'
      click_on 'Accept'

      expect(page).to have_content 'Invite has been accepted'
      expect(page).to have_content 'Visit OpenNebula'
    end

    context 'with an already accepted invite' do
      before do
        Invite::Accept.(
          id: token,
          current_user: double(:user, uid: '123', one_username: 'x', one_password: 'y'),
          invite: {accept_terms_of_service: '1'}
        )
      end

      it "can't be accepted again" do
        visit verify_invite_path(token)
        expect(page).to have_content 'Your invitation has expired'
      end
    end
  end
end
