require 'feature_helper'

describe InvitesController, :feature do
  let(:one_user) { build(:one_user) }
  before { allow(One::Client).to receive(:user_by_password).and_return(one_user) }
  let(:groups) { build_list(:one_group, 1) }
  before { allow(One::Client).to receive(:groups).and_return(groups) }
  let(:current_user) { build(:current_user) }

  context 'invite' do
    let!(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: current_user
      ).model
    end

    it 'lists invites' do
      visit '/invites'
      expect(page).to have_content ['foo@bar.com', 'users', 'Group Administrator', 'Pending'].join('')
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

    it 'revokes invites' do
      visit '/invites'
      click_on 'Revoke'
      expect(page).to have_content ['foo@bar.com', 'users', 'Group Administrator', 'Revoked'].join('')
    end
  end

  context 'accept' do
    before { allow(InviteToken).to receive(:random).and_return(InviteToken.new(token)) }
    let(:token) { 'invite_token' }
    let!(:invite) do
      Invite::Create.(
        invite: {email: 'foo@bar.com', group_id: 1, role: Role.group_admin},
        current_user: current_user
      ).model
    end

    before { expect(One::CreateUser).to receive(:call) }

    it 'accepts invites' do
      visit verify_invite_path(token)

      expect(page).to have_content 'Accept your invitation'

      click_on 'Accept'

      expect(page).to have_content 'Accept terms of service is required'

      check 'I agree to the terms of service'
      click_on 'Accept'

      expect(page).to have_content 'Invite has been accepted'
      expect(page).to have_content 'Visit OpenNebula'
    end

    it 'rejects accepting an already accepted invite' do
      visit verify_invite_path(token)
      check 'I agree to the terms of service'

      Invite::Accept.(
        id: token,
        current_user: current_user,
        invite: {accept_terms_of_service: '1'}
      )

      click_on 'Accept'
      expect(page).to have_content 'Your invitation has expired.'
    end

    context 'with an already accepted invite' do
      before do
        Invite::Accept.(
          id: token,
          current_user: current_user,
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
