require 'rails_helper'

describe CurrentUser do
  let(:current_user) do
    CurrentUser.new(
      'isaac',
      'Sir Isaac Newton',
      'university-example.org',
      'isaac@university-example.org',
      edu_person_entitlement
    )
  end
  let(:edu_person_entitlement) { Rails.application.config.surfsara_admin_entitlement }
  let(:groups) { build_list(:one_group, 1) }
  let(:one_user) { build(:one_user) }

  describe '#uid' do
    it 'returns the value of the Shib-uid header' do
      expect(current_user.uid).to eq('isaac')
    end
  end

  describe '#common_name' do
    it 'returns the value of the Shib-commonName header' do
      expect(current_user.common_name).to eq('Sir Isaac Newton')
    end
  end

  describe '#home_organization' do
    it 'returns the value of the Shib-homeOrganization header' do
      expect(current_user.home_organization).to eq('university-example.org')
    end
  end

  describe '#remote_user' do
    it 'returns the value of the REMOTE_USER header' do
      expect(current_user.remote_user).to eq('isaac@university-example.org')
    end
  end

  describe '#edu_person_entitlement' do
    it 'returns the value of the Shib-eduPersonEntitlement header' do
      expect(current_user.edu_person_entitlement).to eq('urn:x-surfnet:surfsara.nl:opennebula:admin')
    end
  end

  describe '#proposed_one_username' do
    it 'returns a unique identifier for the OpenConext user' do
      expect(current_user.proposed_one_username).to eq('isaac@university-example.org')
    end
  end

  describe '#one_user' do
    let(:one_user) { build(:one_user) }

    before do
      expect_any_instance_of(One::Client)
        .to receive(:user_by_password)
        .with('isaac@university-example.org')
        .and_return(one_user)
    end

    it 'returns the ONE user based on its unique identifier (REMOTE_USER) in OpenConext' do
      expect(current_user.one_user).to eq(one_user)
    end
  end

  describe '#admin_groups' do
    subject { current_user.admin_groups }

    context 'given an entitlement for SURFsara admin' do
      it 'retuns the all admin groups configured in ONE' do
        expect_any_instance_of(One::Client).to receive(:groups).and_return(groups)
        expect(subject).to eq(groups)
      end
    end

    context 'given no entitlement for SURFsara admin' do
      let(:edu_person_entitlement) { nil }

      context 'given a ONE user' do
        before { expect_any_instance_of(One::Client).to receive(:user_by_password).and_return(one_user) }

        it 'retuns the admin groups configured in ONE' do
          expect_any_instance_of(One::Client).to receive(:groups_for_admin).with(one_user.id).and_return(groups)
          expect(subject).to eq(groups)
        end
      end

      context 'given no ONE user' do
        before { expect_any_instance_of(One::Client).to receive(:user_by_password).and_return(nil) }

        it 'returns an empty array' do
          expect(subject).to be_empty
        end
      end
    end
  end

  describe '#role' do
    subject { current_user.role }

    context 'given an entitlement for SURFsara admin' do
      it 'returns surfsara_admin' do
        expect(subject).to eq(Role.surfsara_admin)
      end
    end

    context 'given no entitlement for SURFsara admin' do
      let(:edu_person_entitlement) { nil }
      before { expect_any_instance_of(One::Client).to receive(:user_by_password).and_return(one_user) }

      context 'and the current user is admin of at least 1 group' do
        before do
          expect_any_instance_of(One::Client).to receive(:groups_for_admin).with(one_user.id).and_return(groups)
        end

        it 'returns group_admin' do
          expect(subject).to eq(Role.group_admin)
        end
      end

      context 'and the curent user is not known in OpenNebula' do
        let(:one_user) { nil }
        before { expect_any_instance_of(One::Client).to receive(:user_by_password).and_return(one_user) }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'and the current user is not an admin of any groups' do
        before { expect_any_instance_of(One::Client).to receive(:groups_for_admin).with(one_user.id).and_return([]) }

        it 'returns member' do
          expect(subject).to eq(Role.member)
        end
      end
    end
  end

  describe '#surfsara_admin?' do
    subject { current_user.surfsara_admin? }

    context 'given an entitlement for SURFsara admin' do
      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'given multiple entitlements including one for SURFsara admin' do
      let(:edu_person_entitlement) do
        "#{Rails.application.config.surfsara_admin_entitlement},urn:mace:terena.org:tcs:personal-user-example"
      end

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'given an entitlement not for SURFsara admin' do
      let(:edu_person_entitlement) { 'bogus' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'given no entitlement' do
      let(:edu_person_entitlement) { nil }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#group_admin?' do
    subject { current_user.group_admin? }

    context 'given an entitlement for SURFsara admin' do
      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'given no entitlement for SURFsara admin' do
      let(:edu_person_entitlement) { nil }
      before { expect_any_instance_of(One::Client).to receive(:user_by_password).and_return(one_user) }

      context 'and the current user is admin of at least 1 group' do
        before do
          expect_any_instance_of(One::Client).to receive(:groups_for_admin).with(one_user.id).and_return(groups)
        end

        it 'returns group_admin' do
          expect(subject).to be_truthy
        end
      end

      context 'and the current user is not an admin of any groups' do
        before { expect_any_instance_of(One::Client).to receive(:groups_for_admin).with(one_user.id).and_return([]) }

        it 'returns nil' do
          expect(subject).to be_falsey
        end
      end
    end
  end
end
