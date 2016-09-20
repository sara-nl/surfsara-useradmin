FactoryGirl.define do
  factory :invite do
    email 'someone@there.org'
    token 'secret'
    group_id 1
    group_name 'users'
    role 'admin'

    trait :pending

    trait :accepted do
      accepted_at { Time.current }
      accepted_by 'socrates'
    end

    trait :expired do
      created_at { 1.year.ago }
    end
  end
end
