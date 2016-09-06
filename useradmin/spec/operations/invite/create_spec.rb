require 'rails_helper'

describe Invite::Create do
  let(:run) { Invite::Create.run(params) }
  let(:res) { run.first }
  let(:op) { run.last }
  let(:email_address) { 'john.doe@example.com' }

  context 'with valid input' do
    let(:params) { {invite: {email: email_address}} }

    before { run }

    it 'persists valid input' do
      expect(res).to be_truthy
      expect(op.model.persisted?).to be_truthy
      expect(op.model.email).to eq email_address
    end

    it 'emails an invite to the given email address' do
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq [email_address]
    end
  end

  context 'with invalid input' do
    let(:params) { {invite: {email: nil}} }

    it 'rejects invalid input' do
      expect(res).to be_falsey
      expect(op.model.persisted?).to be_falsey
    end
  end
end
