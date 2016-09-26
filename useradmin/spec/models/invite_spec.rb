require 'rails_helper'

describe Invite do
  describe '#status' do
    subject { invite.status }

    context 'given an accepted invite' do
      let(:invite) { build(:invite, :accepted) }
      it { is_expected.to eq(Invite::STATUS_ACCEPTED) }
    end

    context 'given a revoked invite' do
      let(:invite) { build(:invite, :revoked) }
      it { is_expected.to eq(Invite::STATUS_REVOKED) }
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

    context 'given a revoked invite' do
      let(:invite) { create(:invite, :revoked) }
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

  describe '#expired_at' do
    subject { invite.expired_at }

    context 'given a pending invite' do
      let(:invite) { create(:invite, :pending) }

      it { is_expected.to be_nil }
    end

    context 'given an expired invite' do
      let(:invite) { create(:invite, :expired) }

      it { is_expected.to eq(invite.created_at + Rails.application.config.invites.expire_after) }
    end
  end

  describe '#normalize_email' do
    let(:invite) { build(:invite, email: "  Bforma@zilverline.com \n") }
    before { invite.valid? }
    subject { invite.email }

    it 'normalizes emails' do
      is_expected.to eq('bforma@zilverline.com')
    end

    context 'given the email is not present' do
      let(:invite) { build(:invite, email: nil) }

      it 'leaves the value as is' do
        is_expected.to be_nil
      end
    end
  end
end
