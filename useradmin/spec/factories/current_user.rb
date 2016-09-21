FactoryGirl.define do
  factory :current_user, class: OpenStruct do
    uid 'isaac'
    one_username 'isaac@university-example.org'
    one_password '3d21c8a6d89e3332e3d388852f99d5e5ce114ff9'
    admin_groups []
  end
end
