# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    collectivity do
      factored_publisher = publisher || build(:publisher)
      association(:collectivity, publisher: factored_publisher)
    end

    name      { Faker::Book.title }
    form_type { Report::FORM_TYPES.sample }

    traits_for_enum :form_type, Report::FORM_TYPES

    sequence(:reference) do |n|
      month = Time.current.strftime("%Y-%m")
      index = n.to_s.rjust(4, "0")
      "#{month}-#{index}"
    end

    trait :transmitted do
      transmitted_at { Time.current }
    end

    trait :approved do
      transmitted_at { Time.current }
      approved_at    { Time.current }
    end

    trait :rejected do
      transmitted_at { Time.current }
      rejected_at    { Time.current }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :sandbox do
      sandbox { true }
    end

    trait :completed do
      completed { true }
    end

    trait :with_reports do
      transient do
        report_size { 1 }
      end

      reports do
        # First, build a collection of random communes which are respecting the collectivity territory.
        # It will save time by reducing the number of factories to create and SQL queries to perform.
        #
        communes_size = [report_size, 5].min
        territory     = collectivity.territory

        case territory
        when Commune
          communes    = [territory]
        when Departement
          communes    = Array.new(communes_size) { association(:commune, departement: territory) }
        when EPCI
          departement = territory.departement || association(:departement)
          communes    = Array.new(communes_size) { association(:commune, departement: departement, epci: territory) }
        when Region
          departement = association(:departement, region: territory)
          communes    = Array.new(communes_size) { association(:commune, departement: departement) }
        end

        # Finally, build the list of reports, randomly assigning one the communes.
        #
        Array.new(report_size) do
          association :report,
            publisher:    publisher,
            collectivity: collectivity,
            package:      instance,
            completed:    completed,
            commune:      communes.sample
        end
      end
    end

    trait :packed_through_web_ui do
      transient do
        publisher { association(:publisher) }
      end

      collectivity { association(:collectivity, publisher: publisher) }
      with_reports
    end

    trait :packed_through_api do
      publisher    { association(:publisher) }
      collectivity { association(:collectivity, publisher: publisher) }
      with_reports
    end

    trait :packed_for_ddfip do
      transient do
        ddfip { association(:ddfip) }
      end

      # First, create a random collectivity
      # The collectivity territory should be on the DDIP departement and respect the build strategy.
      #
      collectivity do
        departement    = ddfip.departement
        territory_type = %i[commune epci departement].sample
        territory      = departement if territory_type == :departement
        territory    ||= association(territory_type, departement: departement)

        association(:collectivity, :commune, territory: territory)
      end

      # Then build reports using `with_reports` traits
      # The trait will build reports on communes which are respecting the collectivity territory
      with_reports
    end

    trait :transmitted_through_web_ui do
      transmitted
      packed_through_web_ui
    end

    trait :transmitted_through_api do
      transmitted
      packed_through_api
    end

    trait :transmitted_to_ddfip do
      transmitted
      packed_for_ddfip
    end
  end
end
