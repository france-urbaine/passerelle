# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    collectivity
    name      { Faker::Book.title }
    action    { Package::ACTIONS.sample }

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

    trait :with_reports do
      transient do
        report_size { 1 }
        sandbox     { false }
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
          association(:report,
            publisher:    publisher,
            collectivity: collectivity,
            sandbox:      sandbox,
            package:      instance,
            commune:      communes.sample)
        end
      end
    end
  end
end
