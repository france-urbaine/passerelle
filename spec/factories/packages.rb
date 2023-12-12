# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    transient do
      # Let you define the collectivity publisher without specifying
      # the collectivity or assigning the publisher to the package.
      #
      # Example:
      #   package = create(:package, collectivity_publisher: publisher)
      #   expect(package.collectivity.publisher).to be(publisher)
      #
      collectivity_publisher { publisher || association(:publisher) }
    end

    collectivity { association(:collectivity, publisher: collectivity_publisher) }
    transmission { association(:transmission, :completed, collectivity:, publisher:, sandbox:) }

    sequence :reference do |n|
      month = Time.current.strftime("%Y-%m")
      index = n.to_s.rjust(4, "0")

      "#{month}-#{index}"
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :sandbox do
      sandbox { true }
    end

    trait :with_reports do
      transient do
        reports_size { 1 }
      end

      reports do
        next [] unless reports_size&.positive?

        # First, build a collection of random communes which are respecting the collectivity territory.
        # It will save time by reducing the number of factories to create and SQL queries to perform.
        #
        communes_size = [reports_size, 5].min
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
        Array.new(reports_size) do
          association :report, :transmitted,
            package:      instance,
            publisher:    publisher,
            collectivity: collectivity,
            transmission: transmission,
            ddfip:        ddfip,
            sandbox:      sandbox,
            commune:      communes.sample
        end
      end
    end

    trait :transmitted_through_web_ui do
      after :build, :stub do |package|
        raise "invalid factory: a publisher is assigned to the package" if package.publisher
      end
    end

    trait :transmitted_through_api do
      publisher { association(:publisher) }
    end

    trait :transmitted_to_ddfip do
      ddfip { association(:ddfip) }
    end
  end
end
