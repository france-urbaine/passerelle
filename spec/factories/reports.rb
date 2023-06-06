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
      transmitted_package { false }
      approved_package    { false }
      rejected_package    { false }
      debated_package     { false }
    end

    collectivity do
      publisher = self.publisher || build(:publisher)
      association(:collectivity, publisher: publisher)
    end

    package do
      collectivity = self.collectivity
      traits = [].tap do |array|
        array << :transmitted if transmitted_package
        array << :approved    if approved_package
        array << :rejected    if rejected_package
        array << :debated     if debated_package
      end

      association(:package, *traits, collectivity: collectivity, publisher: self.publisher)
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

    action  { Report::ACTIONS.sample }
    subject { Report::SUBJECTS.sample }

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

    trait :transmitted do
      transmitted_package { true }
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
  end
end
