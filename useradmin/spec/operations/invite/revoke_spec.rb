require 'rails_helper'

describe Invite::Revoke do
  let(:current_user) { build(:current_user) }
  let!(:invite) do
    Invite::Create.(
      invite: attributes_for(:invite),
      current_user: current_user
    ).model
  end

  subject(:revoke) { Invite::Revoke.run(id: invite.id, current_user: current_user) }

  it 'revokes the invite' do
    expect { revoke }.to change { invite.reload.status }.from(Invite::STATUS_PENDING).to(Invite::STATUS_REVOKED)
  end

  context 'given an already revoked invite' do
    before { Invite::Revoke.run(id: invite.id, current_user: current_user) }

    it 'fails' do
      expect { revoke }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
