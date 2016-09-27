FactoryGirl.define do
  factory :current_user, class: OpenStruct do
    uid 'isaac'
    proposed_one_username 'isaac@university-example.org'
    edu_person_principal_name '3d21c8a6d89e3332e3d388852f99d5e5ce114ff9'
    admin_groups { build_list(:one_group, 1) }
  end
end
