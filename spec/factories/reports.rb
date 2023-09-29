# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    transient do
      # Let you define the collectivity publisher without specifying
      # the collectivity or assigning the publisher to the report.
      #
      # Example:
      #   report = create(:report, collectivity_publisher: publisher)
      #   expect(report.collectivity.publisher).to be(publisher)
      #
      collectivity_publisher { publisher || association(:publisher) }
    end

    collectivity { association(:collectivity, publisher: collectivity_publisher) }

    form_type { Report::FORM_TYPES.sample }
    anomalies { [] }

    traits_for_enum :form_type, Report::FORM_TYPES

    commune do
      territory = collectivity.territory

      case territory
      when Commune
        territory
      when EPCI
        departement = territory.departement || association(:departement)
        association(:commune, epci: territory, departement: departement)
      when Departement
        association(:commune, departement: territory)
      when Region
        departement = association(:departement, region: territory)
        association(:commune, departement: departement)
      end
    end

    trait :low_priority do
      priority { "low" }
    end

    trait :medium_priority do
      priority { "medium" }
    end

    trait :high_priority do
      priority { "high" }
    end

    # Report status

    trait :completed do
      completed_at { Time.current }
    end

    trait :sandbox do
      completed
      made_through_api
      sandbox { true }
    end

    trait :in_active_transmission do
      completed
      transmission { association(:transmission, collectivity:, publisher:, sandbox:) }
    end

    trait :transmitted do
      completed
      transmission { association(:transmission, :completed, collectivity:, publisher:, sandbox:) }
      package      { association(:package, collectivity:, publisher:, transmission:, sandbox:) }

      sequence :reference do |n|
        index = n.to_s.rjust(5, "0")
        "#{package.reference}-#{index}"
      end
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :assigned do
      transmitted
      package { association(:package, :assigned, collectivity:, publisher:, transmission:) }
    end

    trait :returned do
      transmitted
      package { association(:package, :returned, collectivity:, publisher:, transmission:) }
    end

    trait :approved do
      assigned
      approved_at { Time.current }
    end

    trait :rejected do
      assigned
      rejected_at { Time.current }
    end

    trait :debated do
      assigned
      debated_at { Time.current }
    end

    # Report origin

    trait :made_through_web_ui do
      after :build, :stub do |report|
        raise "invalid factory: a publisher is assigned to the report"  if report.publisher
        raise "invalid factory: a publisher is assigned to the package" if report.package&.publisher
      end
    end

    trait :made_through_api do
      in_active_transmission
      publisher { association(:publisher) }
    end

    trait :transmitted_through_web_ui do
      made_through_web_ui
      transmitted
    end

    trait :transmitted_through_api do
      made_through_api
      transmitted
    end

    # Report destination

    trait :made_for_ddfip do
      transient do
        ddfip { association(:ddfip) }
      end

      collectivity do
        departement = ddfip.departement
        territory =
          case %i[commune epci departement].sample
          when :departement then departement
          when :epci        then association :epci, departement: departement
          when :commune     then association :commune, departement: departement
          end

        association(:collectivity, :commune, territory:, publisher: collectivity_publisher)
      end
    end

    trait :made_for_office do
      made_for_ddfip

      transient do
        office { association(:office, :with_communes, ddfip:) }
      end

      commune   { office.communes.sample }
      form_type { office.competences.sample }
    end

    trait :transmitted_to_ddfip do
      made_for_ddfip
      transmitted
    end

    trait :assigned_by_ddfip do
      made_for_ddfip
      assigned
    end

    trait :returned_by_ddfip do
      made_for_ddfip
      returned
    end

    trait :assigned_to_office do
      made_for_office
      assigned
    end
  end
end
