# frozen_string_literal: true

FactoryBot.define do
  factory :transmission do
    collectivity do
      factored_publisher = publisher || build(:publisher)
      association(:collectivity, publisher: factored_publisher)
    end

    trait :completed do
      completed_at { Time.current }
    end

    trait :sandbox do
      sandbox { true }
    end

    trait :made_through_web_ui do
      transient do
        publisher { association(:publisher) }
      end

      collectivity { association(:collectivity, publisher: publisher) }
    end

    trait :made_through_api do
      publisher    { association(:publisher) }
      collectivity { association(:collectivity, publisher: publisher) }
    end

    trait :completed_through_web_ui do
      completed
      made_through_web_ui
    end

    trait :completed_through_api do
      completed
      made_through_api
    end
  end
end
