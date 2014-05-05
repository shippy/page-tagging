FactoryGirl.define do
  factory :node do
    url Faker::Internet.url
    tag  nil
    tagger Faker::Name.name
    rank Faker::Number.digit
  end
end