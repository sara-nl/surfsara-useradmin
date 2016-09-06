require 'rails_helper'

describe Invite::Update do
  let(:invite) { Invite::Create.(invite: { email: 'john.doe@example.com' }).model }
  let(:params) { {id: invite.id, invite: {email: 'john.doe@new.com'}} }

  it 'is updated' do
    res, op = Invite::Update.run(params)

    expect(res).to be_truthy
    expect(op.model.email).to eq 'john.doe@new.com'
  end
end
