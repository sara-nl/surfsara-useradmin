FactoryGirl.define do
  factory :one_user, class: One::User do
    id 1
    name 'isaac@university-example.org'
    password 'isaac@university-example.org'
    group_ids [1]

    trait :no_group_memberships do
      group_ids []
    end
  end
end
