FactoryGirl.define do
  factory :current_user do
    uid 'isaac'
    common_name 'Sir Isaac Newton'
    home_organization 'university-example.org'
    remote_user '3d21c8a6d89e3332e3d388852f99d5e5ce114ff9'

    surfsara_admin

    trait :member do
      edu_person_entitlement ''
    end

    trait :surfsara_admin do
      edu_person_entitlement 'urn:x-surfnet:surfsara.nl:opennebula:admin'
    end
  end
end
