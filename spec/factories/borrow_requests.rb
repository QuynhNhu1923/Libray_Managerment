FactoryBot.define do
  factory :borrow_request do
    association :user
    request_date { Time.current.to_date - 3 }
    start_date { request_date + 1 }
    end_date { start_date + 7 }
    status { :pending }

    trait :non_expired do
      request_date { Time.current.to_date }
      start_date { Time.current.to_date + 5 }
      end_date { start_date + 5 }
    end

    trait :rejected do
      status { :rejected }
      admin_note { "Không đủ điều kiện mượn sách" }
      after(:build) do |br|
        br.rejected_by_admin ||= build(:user, :admin)
      end
    end

    trait :approved do
      status { :approved }
      request_date { 3.days.ago.to_date }
      start_date { 1.day.ago.to_date } # trước ngày hiện tại
      end_date { start_date + 7 }
      approved_date { start_date }
      after(:build) do |br|
        br.approved_by_admin ||= build(:user, :admin)
      end
    end

    trait :borrowed do
      status { :borrowed }
      request_date { 3.days.ago.to_date }
      start_date { 1.day.ago.to_date }
      actual_borrow_date { Time.current.to_date } # luôn ≥ start_date
      approved_date { start_date }
      after(:build) do |br|
        br.approved_by_admin ||= build(:user, :admin)
        br.borrowed_by_admin ||= build(:user, :admin)
      end
    end

    trait :returned do
      status { :returned }
      approved_date { request_date }
      actual_borrow_date { start_date }
      actual_return_date { start_date + 1 }
      after(:build) do |br|
        br.approved_by_admin ||= build(:user, :admin)
        br.borrowed_by_admin ||= build(:user, :admin)
        br.returned_by_admin ||= build(:user, :admin)
      end
    end

    after(:create) do |br|
      rand(1..3).times { create(:borrow_request_item, borrow_request: br) }
    end
  end
end
