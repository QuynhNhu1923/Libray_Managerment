FactoryBot.define do
  factory :review do
    association :user
    association :book
    score { 5 }
    comment { "Great book!" }
  end
end
