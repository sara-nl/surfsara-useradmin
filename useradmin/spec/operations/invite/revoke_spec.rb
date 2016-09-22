require 'rails_helper'

describe Invite::Revoke do
  let!(:invite) do
    Invite::Create.(
      invite: {email: 'john.doe@example.com', group_id: 1, role: Role.group_admin},
      current_user: double(admin_groups: [double(id: 1, name: 'foo')])
    ).model
  end

  it 'is destroyed' do
    expect { Invite::Revoke.run(id: invite.id) }
      .to change(Invite, :count).from(1).to(0)
  end
end
