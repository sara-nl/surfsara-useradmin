require 'rails_helper'

describe CurrentUser do
  let(:current_user) { CurrentUser.new(double({})) }

  describe '#group_admin?' do
    subject { current_user.group_admin? }

    context 'when not a surfsara_admin' do
      before { allow(current_user).to receive(:surfsara_admin?).and_return(false) }

      context 'with groups' do
        before { allow(current_user).to receive(:admin_groups).and_return([double({})]) }
        it { is_expected.to be_truthy }
      end

      context 'without groups' do
        before { allow(current_user).to receive(:admin_groups).and_return([]) }
        it { is_expected.to be_falsey }
      end
    end

    context 'when a surfsara_admin' do
      before { allow(current_user).to receive(:surfsara_admin?).and_return(true) }
      it { is_expected.to be_falsey }
    end
  end
end
