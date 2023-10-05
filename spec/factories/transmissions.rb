# frozen_string_literal: true

FactoryBot.define do
  factory :transmission do
    transient do
      # Let you define the collectivity publisher without specifying
      # the collectivity or assigning the publisher to the transmission.
      #
      # Example:
      #   transmisssion = create(:transmisssion, collectivity_publisher: publisher)
      #   expect(transmisssion.collectivity.publisher).to be(publisher)
      #
      collectivity_publisher { publisher || association(:publisher) }
    end

    collectivity do
      association(:collectivity, publisher: collectivity_publisher)
    end

    user do
      collectivity.users.first || association(:user, organization: collectivity) unless publisher
    end

    trait :sandbox do
      sandbox { true }
    end

    trait :completed do
      completed_at { Time.current }
    end

    trait :made_through_web_ui do
      after :build, :stub do |transmission|
        raise "invalid factory: a publisher is assigned to the transmission" if transmission.publisher
      end
    end

    trait :made_through_api do
      user              { nil }
      publisher         { association(:publisher) }
      oauth_application { association(:oauth_application, owner: publisher) }

      after :build, :stub do |transmission|
        raise "invalid factory: an user is assigned to the transmission" if transmission.user
      end
    end

    trait :completed_through_web_ui do
      made_through_web_ui
      completed
    end

    trait :completed_through_api do
      made_through_api
      completed
    end

    trait :with_reports do
      transient do
        reports_size { 1 }
      end

      reports do
        Array.new(reports_size) do
          association :report, :completed, transmission: instance, collectivity:, publisher:
        end
      end
    end
  end
end
