# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    # We first build a report without collectivity,
    # we'll assign it in an after(:build) callback to ensure conformity.
    #
    #   build(:report)
    #     - No collectivity assigned to the report
    #     - A new collectivity is assigned to the package
    #     - The package collectivity is assigned to the report after build
    #
    #   build(:report, package: one_package)
    #     - No collectivity assigned to the report
    #     - The package should already have a collectivity
    #     - The package collectivity is assigned to the report after build
    #
    #   build(:report, collectivity: one_collectivity)
    #     - A collectivity is assigned to the report
    #     - The new package inherits the same collectivity
    #
    # We also allow to define the status of the package through transient attributes
    #
    transient do
      package_sandbox       { false }
      package_transmitted   { false }
      package_assigned      { false }
      package_returned      { false }
      packed_through_web_ui { publisher.nil? }
    end

    package do
      package_traits = []
      package_traits << :sandbox               if package_sandbox
      package_traits << :transmitted           if package_transmitted
      package_traits << :assigned              if package_assigned
      package_traits << :returned              if package_returned
      package_traits << :packed_through_web_ui if packed_through_web_ui

      attributes = { form_type: form_type }
      attributes[:collectivity] = collectivity if collectivity
      attributes[:publisher]    = publisher    if publisher

      association :package, *package_traits, **attributes
    end

    # The commune shoud be on the territory of the package collectivity
    # It will save time by reducing the number of factories to create and SQL queries to perform.
    #
    commune do
      territory = package.collectivity.territory

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

    form_type { Report::FORM_TYPES.sample }
    anomalies { [] }

    traits_for_enum :form_type, Report::FORM_TYPES

    sequence :reference do |n|
      index = n.to_s.rjust(5, "0")
      "#{package.reference}-#{index}"
    end

    after :build, :stub do |report|
      report.collectivity ||= report.package.collectivity
      report.publisher    ||= report.package.publisher
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

    trait :completed do
      completed { true }
    end

    trait :sandbox do
      package_sandbox { true }
    end

    trait :transmitted do
      package_transmitted{ true }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :approved do
      transmitted
      approved_at { Time.current }
    end

    trait :rejected do
      transmitted
      rejected_at { Time.current }
    end

    trait :debated do
      transmitted
      debated_at { Time.current }
    end

    trait :reported_through_web_ui do
      transient do
        publisher             { association(:publisher) }
        packed_through_web_ui { true }
      end

      collectivity { association(:collectivity, publisher: publisher) }

      after :build, :stub do |report|
        raise "invalid factory: a publisher is assigned to report" if report.publisher
        raise "invalid factory: a publisher is assigned to package" if report.package.publisher
      end
    end

    trait :reported_through_api do
      publisher    { association(:publisher) }
      collectivity { association(:collectivity, publisher: publisher) }
    end

    trait :reported_for_ddfip do
      transient do
        ddfip { association(:ddfip) }
      end

      collectivity do
        publisher = self.publisher || build(:publisher)
        departement = ddfip.departement
        territory =
          case %i[commune epci departement].sample
          when :departement then departement
          when :epci        then association :epci, departement: departement
          when :commune     then association :commune, departement: departement
          end

        association(:collectivity, :commune, territory:, publisher:)
      end
    end

    trait :reported_for_office do
      reported_for_ddfip

      transient do
        ddfip  { association(:ddfip) }
        office { association(:office, :with_communes, ddfip: ddfip) }
      end

      commune   { office.communes.sample }
      form_type { office.competences.sample }
    end

    trait :transmitted_through_web_ui do
      transmitted
      reported_through_web_ui
    end

    trait :transmitted_through_api do
      transmitted
      reported_through_api
    end

    trait :transmitted_to_ddfip do
      transmitted
      reported_for_ddfip
    end

    trait :package_assigned_to_office do
      transmitted
      reported_for_office
      package_assigned { true }
    end

    trait :package_assigned_by_ddfip do
      transmitted
      reported_for_ddfip
      package_assigned { true }
    end

    trait :package_returned_by_ddfip do
      transmitted
      reported_for_ddfip
      package_returned { true }
    end
  end
end
