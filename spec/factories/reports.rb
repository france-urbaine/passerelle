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
      package_sandbox     { false }
      package_transmitted { false }
      package_approved    { false }
      package_rejected    { false }
      package_traits do
        [].tap do |array|
          array << :sandbox     if package_sandbox
          array << :transmitted if package_transmitted
          array << :approved    if package_approved
          array << :rejected    if package_rejected
        end
      end
    end

    collectivity do
      factored_publisher = publisher || build(:publisher)
      association(:collectivity, publisher: factored_publisher)
    end

    package do
      factored_collectivity = collectivity
      factored_publisher    = publisher

      association :package, *package_traits,
        collectivity: factored_collectivity,
        publisher:    factored_publisher
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

    action { package.action }

    subject do
      Report::SUBJECTS.select { |subject| subject.start_with?(action) }.sample
    end

    sequence(:reference) do |n|
      index = n.to_s.rjust(5, "0")
      "#{package.reference}-#{index}"
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

    trait :transmitted do
      package_transmitted { true }
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
        publisher { association(:publisher) }
      end

      collectivity { association(:collectivity, publisher: publisher) }
      package do
        association(:package, :packed_through_web_ui, *package_traits,
          collectivity: collectivity,
          publisher: publisher)
      end
    end

    trait :reported_through_api do
      publisher    { association(:publisher) }
      collectivity { association(:collectivity, publisher: publisher) }
      package do
        association(:package, :packed_through_api, *package_traits,
          collectivity: collectivity,
          publisher: publisher)
      end
    end

    trait :reported_for_ddfip do
      transient do
        ddfip { association(:ddfip) }
      end

      collectivity do
        departement    = ddfip.departement
        territory_type = %i[commune epci departement].sample
        territory      = departement if territory_type == :departement
        territory    ||= association(territory_type, departement: departement)

        association(:collectivity, :commune, territory: territory)
      end

      package do
        traits     = package_traits
        attributes = { collectivity: collectivity, ddfip: ddfip }

        association(:package, :packed_for_ddfip, *traits, **attributes)
      end
    end

    trait :reported_for_office do
      reported_for_ddfip

      transient do
        office do
          # FIXME: Not all reports have been implemented.
          # We need to create an office with its competence compatible with available reports
          action = Report::ACTIONS.sample
          association :office, :with_communes, action: action
        end

        ddfip { office.ddfip }
      end

      commune { office.communes.sample }
      action  { office.action }
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

    trait :package_approved_by_ddfip do
      transmitted
      package_approved { true }
      reported_for_ddfip
    end

    trait :package_rejected_by_ddfip do
      transmitted
      package_rejected { true }
      reported_for_ddfip
    end
  end
end
