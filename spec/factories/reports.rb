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
      territory = collectivity&.territory

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

    trait :sandbox do
      sandbox { true }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    after :stub do |report|
      report.generate_sibling_id
      report.compute_address
    end

    # Report state
    # --------------------------------------------------------------------------

    trait :draft do
      state { "draft" }
    end

    trait :ready do
      state        { "ready" }
      completed_at { Time.current }
      anomalies    { Report::FORM_TYPE_ANOMALIES[form_type][0, 1] }
      date_constat { rand(0..5).days.ago }

      situation_invariant do
        Faker::Number.leading_zero_number(digits: 10) unless form_type.start_with?("creation_")
      end

      situation_annee_majic do
        6.months.ago.year
      end

      situation_parcelle do
        [
          Array("A".."Z").sample(2).join,
          Faker::Number.leading_zero_number(digits: 4)
        ].join(" ")
      end

      situation_numero_voie  { Faker::Address.building_number }
      situation_libelle_voie { Faker::Address.street_name }
      situation_code_rivoli  { Faker::Number.leading_zero_number(digits: 4) }
    end

    trait :in_active_transmission do
      ready
      transmission { association(:transmission, collectivity:, publisher:, sandbox:) }
    end

    trait :transmitted do
      ready

      transmission   { association(:transmission, :completed, collectivity:, publisher:, sandbox:) }
      package        { association(:package, collectivity:, publisher:, sandbox:, transmission:, ddfip:) }
      state          { "transmitted" }
      transmitted_at { Time.current }

      sequence :reference do |n|
        index = n.to_s.rjust(5, "0")
        "#{package.reference}-#{index}"
      end
    end

    trait :acknowledged do
      transmitted

      state           { "acknowledged" }
      acknowledged_at { Time.current }
    end

    trait :accepted do
      acknowledged

      state       { "accepted" }
      accepted_at { Time.current }
    end

    trait :assigned do
      accepted

      state       { "assigned" }
      assigned_at { Time.current }
    end

    trait :rejected do
      acknowledged

      state       { "rejected" }
      returned_at { Time.current }
    end

    trait :resolved do
      assigned

      state       { %w[applicable inapplicable].sample }
      resolved_at { Time.current }

      resolution_motif do
        if applicable? || approved?
          I18n.t("enum.resolution_motif.applicable").keys.sample
        else
          I18n.t("enum.resolution_motif.inapplicable").keys.sample
        end
      end
    end

    trait :applicable do
      resolved

      state { "applicable" }
    end

    trait :inapplicable do
      resolved

      state { "inapplicable" }
    end

    trait :approved do
      applicable

      state       { "approved" }
      returned_at { Time.current }
    end

    trait :canceled do
      inapplicable

      state       { "canceled" }
      returned_at { Time.current }
    end

    # Report origin
    # --------------------------------------------------------------------------

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

    trait :transmitted_to_sandbox do
      transmitted_through_api
      sandbox
    end

    # Report destination
    # --------------------------------------------------------------------------

    trait :made_for_ddfip do
      ddfip { association(:ddfip) }
    end

    trait :made_for_office do
      made_for_ddfip

      office { association(:office, :with_communes, ddfip:) }
      commune { office.communes.sample }
      form_type { office.competences.sample }
    end

    trait :transmitted_to_ddfip do
      made_for_ddfip
      transmitted
    end

    # Report workflow by DDFIP & offices
    # --------------------------------------------------------------------------
    trait :acknowledged_by_ddfip do
      made_for_ddfip
      acknowledged
    end

    trait :accepted_by_ddfip do
      made_for_ddfip
      accepted
    end

    trait :assigned_by_ddfip do
      made_for_ddfip
      assigned
    end

    trait :assigned_to_office do
      made_for_office
      assigned
    end

    trait :resolved_by_ddfip do
      assigned_by_ddfip
      resolved
    end

    trait :resolved_as_applicable do
      assigned_to_office
      applicable
    end

    trait :resolved_as_inapplicable do
      assigned_to_office
      inapplicable
    end

    trait :approved_by_ddfip do
      resolved_as_applicable
      approved
    end

    trait :canceled_by_ddfip do
      resolved_as_inapplicable
      canceled
    end

    trait :rejected_by_ddfip do
      made_for_ddfip
      rejected
    end
  end
end
