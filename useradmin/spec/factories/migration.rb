FactoryGirl.define do
  factory :migration do
    one_username 'isaac'
    accepted_by { 'isaac@university-example.org' }
    accepted_at { 5.minutes.ago }
  end
end
