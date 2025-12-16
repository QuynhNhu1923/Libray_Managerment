# spec/factories/categories.rb
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Thể loại #{n}" }
    description { "Mô tả cho thể loại #{name}" }
  end
end
