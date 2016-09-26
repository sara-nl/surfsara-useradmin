FactoryGirl.define do
  factory :invite do
    email 'someone@there.org'
    token { InviteToken.new('secret').hashed }
    group_id 1
    group_name 'users'
    role Role.group_admin

    trait :pending

    trait :accepted do
      accepted_at { Time.current }
      accepted_by 'socrates'
    end

    trait :revoked do
      revoked_at { Time.current }
      revoked_by 'socrates'
    end

    trait :expired do
      created_at { 1.year.ago }
    end
  end
end
