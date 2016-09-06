require 'rails_helper'

describe Invite::Create do
  it 'persists valid input' do
    res, op = Invite::Create.run(invite: { email: 'john.doe@example.com' })

    expect(res).to be_truthy
    expect(op.model.persisted?).to be_truthy
    expect(op.model.email).to eq 'john.doe@example.com'
  end

  it 'rejects invalid input' do
    res, op = Invite::Create.run(invite: { email: nil })

    expect(res).to be_falsey
    expect(op.model.persisted?).to be_falsey
  end
end
