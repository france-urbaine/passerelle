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

    name           { Faker::Book.title }
    form_type      { Report::FORM_TYPES.sample }
    transmitted_at { Time.current }

    traits_for_enum :form_type, Report::FORM_TYPES

    sequence :reference do |n|
      month = Time.current.strftime("%Y-%m")
      index = n.to_s.rjust(4, "0")
      "#{month}-#{index}"
    end

    trait :assigned do
      assigned_at { Time.current }
    end

    trait :returned do
      returned_at { Time.current }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :sandbox do
      sandbox { true }
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
          association :report, :transmitted,
            publisher:    publisher,
            collectivity: collectivity,
            package:      instance,
            transmission: transmission,
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
      publisher    { association(:publisher) }
      collectivity { association(:collectivity, publisher: publisher) }
    end

    trait :transmitted_to_ddfip do
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

        association(:collectivity, :commune, territory: territory, publisher: collectivity_publisher)
      end

      # Then build reports using `with_reports` traits
      # The trait will build reports on communes which are respecting the collectivity territory
      with_reports
    end
  end
end
