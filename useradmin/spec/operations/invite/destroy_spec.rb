require 'rails_helper'

describe Invite::Destroy do
  let!(:invite) { Invite::Create.(invite: { email: 'john.doe@example.com' }).model }

  it 'is destroyed' do
    expect { Invite::Destroy.run(id: invite.id) }
      .to change(Invite, :count).from(1).to(0)
  end
end
