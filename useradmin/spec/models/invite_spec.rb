require 'rails_helper'

describe Invite do
  describe '#status' do
    subject { invite.status }

    context 'given an accepted invite' do
      let(:invite) { build(:invite, :accepted) }
      it { is_expected.to eq(Invite::STATUS_ACCEPTED) }
    end

    context 'given an expired invite' do
      let(:invite) { build(:invite, :expired) }
      it { is_expected.to eq(Invite::STATUS_EXPIRED) }
    end

    context 'given a pending invite' do
      let(:invite) { build(:invite, :pending) }
      it { is_expected.to eq(Invite::STATUS_PENDING) }
    end
  end

  describe '.pending' do
    subject { Invite.pending }

    context 'given an accepted invite' do
      let(:invite) { create(:invite, :accepted) }
      it { is_expected.to_not include(invite) }
    end

    context 'given an expired invite' do
      let(:invite) { create(:invite, :expired) }
      it { is_expected.to_not include(invite) }
    end

    context 'given a pending invite' do
      let(:invite) { create(:invite, :pending) }
      it { is_expected.to include(invite) }
    end
  end
end
