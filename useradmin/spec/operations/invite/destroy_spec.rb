require 'rails_helper'

describe Invite::Destroy, :vcr do
  let!(:invite) { Invite::Create.(invite: { email: 'john.doe@example.com', group_id: 1, role: Role.admin }).model }

  it 'is destroyed' do
    expect { Invite::Destroy.run(id: invite.id) }
      .to change(Invite, :count).from(1).to(0)
  end
end
