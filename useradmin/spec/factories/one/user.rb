FactoryGirl.define do
  factory :one_user, class: One::User do
    id 1
    name 'isaac@university-example.org'
    password 'isaac@university-example.org'
    group_ids [1]
  end
end
