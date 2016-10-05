FactoryGirl.define do
  factory :current_user do
    uid 'isaac'
    common_name 'Sir Isaac Newton'
    home_organization 'university-example.org'
    remote_user 'isaac@university-example.org'
    remote_ip '127.0.0.1'

    surfsara_admin

    trait :member do
      edu_person_entitlement ''
    end

    trait :surfsara_admin do
      edu_person_entitlement 'urn:x-surfnet:surfsara.nl:opennebula:admin'
    end
  end
end
