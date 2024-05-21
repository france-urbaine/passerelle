# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:package).optional }
    it { is_expected.to belong_to(:transmission).optional }
    it { is_expected.to belong_to(:workshop).optional }
    it { is_expected.to belong_to(:commune).optional }
    it { is_expected.to belong_to(:office).optional }
    it { is_expected.to belong_to(:assignee).optional }

    it { is_expected.to have_many(:siblings) }

    it { is_expected.to have_many(:exonerations) }
  end

  # Attachments
  # ----------------------------------------------------------------------------
  describe "attachments" do
    it { is_expected.to have_many_attached(:documents) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:form_type) }

    it { is_expected.to validate_inclusion_of(:form_type).in_array(Report::FORM_TYPES) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w[low medium high]) }

    it "validates uniqueness of #reference" do
      create(:report)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates uniqueness of #reference against discarded records" do
      create(:report, :discarded)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates that :anomalies must be an array" do
      aggregate_failures do
        is_expected.to     allow_value([]).for(:anomalies)
        is_expected.not_to allow_value(nil).for(:anomalies)

        # After setting :anomalies to aything but nil or an Array, ActiveRecord will convert it to an empty array.
        # So we cannot test invalid string with Shoulda matcher:
        #
        #   is_expected.not_to allow_value("foo").for(:anomalies)
      end
    end

    def random_combinaison(values)
      array = values.map { |v| [v] }
      array += Array.new(values.size) { values.sample(2) }
      array.uniq
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting an evaluation_local_habitation" do
      report = build(:report, :evaluation_local_habitation)

      allowed_arrays = random_combinaison(%w[consistance affectation exoneration correctif adresse])
      invalid_arrays = random_combinaison(%w[occupation omission_batie])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting an evaluation_local_professionnel" do
      report = build(:report, :evaluation_local_professionnel)

      allowed_arrays = random_combinaison(%w[consistance affectation exoneration adresse])
      invalid_arrays = random_combinaison(%w[correctif omission_batie])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting a creation form" do
      report = build(:report, :creation_local_habitation)

      allowed_arrays = random_combinaison(%w[omission_batie construction_neuve])
      invalid_arrays = random_combinaison(%w[consistance adresse])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting a habitation local occupation form" do
      report = build(:report, :occupation_local_habitation)

      allowed_arrays = random_combinaison(%w[occupation])
      invalid_arrays = random_combinaison(%w[consistance affectation])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting a professionnel local occupation form" do
      report = build(:report, :occupation_local_professionnel)

      allowed_arrays = random_combinaison(%w[occupation])
      invalid_arrays = random_combinaison(%w[consistance affectation])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it { is_expected.to     allow_values("64102", "2B013", "97101").for(:code_insee) }
    it { is_expected.not_to allow_values("640102", "102").for(:code_insee) }

    it { is_expected.to validate_numericality_of(:situation_annee_majic).is_in(2018..Time.current.year) }

    it { is_expected.to     allow_values("0123456789").for(:situation_invariant) }
    it { is_expected.not_to allow_values("123", "A123456789").for(:situation_invariant) }

    it { is_expected.to     allow_values("A12345", "* 12345", "* 12345 01").for(:situation_numero_ordre_proprietaire) }
    it { is_expected.not_to allow_values("123", "-12345").for(:situation_numero_ordre_proprietaire) }

    it "validates format of parcelles" do
      valid_parcelles   = ["A 0003", "AB 0002", "0A 0003", "01 0093", "001 A 0093", "001 0A 0093", "001 01 0093", "0010A0093", "001AB0093", "001010093", "001A0093", "010093"]
      invalid_parcelles = ["ABC 1", "ABC 0001", "001 0093", "001 001 0093"]

      aggregate_failures do
        is_expected.to     allow_values(*valid_parcelles).for(:situation_parcelle)
        is_expected.not_to allow_values(*invalid_parcelles).for(:situation_parcelle)

        is_expected.to     allow_values(*valid_parcelles).for(:proposition_parcelle)
        is_expected.not_to allow_values(*invalid_parcelles).for(:proposition_parcelle)
      end
    end

    it { is_expected.to validate_numericality_of(:situation_numero_voie).is_in(0..9999) }
    it { is_expected.to validate_numericality_of(:proposition_numero_voie).is_in(0..9999) }

    it { is_expected.to     allow_values("1234", "A345").for(:situation_code_rivoli) }
    it { is_expected.not_to allow_values("123", "-123").for(:situation_code_rivoli) }

    it { is_expected.to     allow_values("1234", "A345").for(:proposition_code_rivoli) }
    it { is_expected.not_to allow_values("123", "-123").for(:proposition_code_rivoli) }
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  describe "callbacks" do
    describe "#generate_sibling_id" do
      it "generates a sibling_id when code INSEE and invariant are provided" do
        report = create(:report, code_insee: "64102", situation_invariant: "1021234567")

        expect(report).to have_attributes(sibling_id: "641021021234567")
      end

      it "lets sibling_id null when code INSEE is missing" do
        report = create(:report, code_insee: nil, situation_invariant: "1021234567")

        expect(report).to have_attributes(sibling_id: nil)
      end

      it "lets sibling_id null when invariant is missing" do
        report = create(:report, code_insee: "64102")

        expect(report).to have_attributes(sibling_id: nil)
      end

      it "resets sibling_id when one of the attribute is removed" do
        report = create(:report, code_insee: "64102", situation_invariant: "1021234567")

        expect {
          report.update(situation_invariant: nil)
        }.to change(report, :sibling_id).to(nil)
      end
    end

    describe "#compute_address", :aggregate_failures do
      it "computes addresses" do
        report = create(:report,
          situation_libelle_voie: "Rue  du 18  mai",
          situation_numero_voie: "45")

        expect(report).to have_attributes(computed_address:          "45 Rue du 18 mai")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai / 45")
      end

      it "computes addresses with a indice of repetition" do
        report = create(:report,
          situation_libelle_voie:      "Rue du 18 MAI",
          situation_numero_voie:       "45",
          situation_indice_repetition: "Ter")

        expect(report).to have_attributes(computed_address:          "45 Ter Rue du 18 MAI")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai / 45 / ter")
      end

      it "computes addresses from situation_adresse, without number" do
        report = create(:report, situation_adresse: "Rue du 18 mai")

        expect(report).to have_attributes(computed_address:          "Rue du 18 mai")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai")
      end

      it "computes addresses from situation_adresse, with a number" do
        report = create(:report, situation_adresse: "15 Rue du 18 mai")

        expect(report).to have_attributes(computed_address:          "15 Rue du 18 mai")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai / 15")
      end

      it "computes addresses from situation_adresse, with a number, separated by a comma" do
        report = create(:report, situation_adresse: "15, Rue du  18 mai")

        expect(report).to have_attributes(computed_address:          "15, Rue du 18 mai")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai / 15")
      end

      it "computes addresses from situation_adresse, with an indice" do
        report = create(:report, situation_adresse: "15 TER  Rue du 18 mai")

        expect(report).to have_attributes(computed_address:          "15 TER Rue du 18 mai")
        expect(report).to have_attributes(computed_address_sort_key: "rue du 18 mai / 15 / ter")
      end
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes reports tagged as sandbox" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."sandbox" = TRUE
        SQL
      end
    end

    describe ".out_of_sandbox" do
      it "scopes reports by excluding those tagged as sandbox" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."sandbox" = FALSE
        SQL
      end
    end

    describe ".in_active_transmission" do
      it "scopes on reports in an active transmission not yet transmitted" do
        expect {
          described_class.in_active_transmission.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" IN ('draft', 'ready')
            AND  "reports"."transmission_id" IS NOT NULL
        SQL
      end
    end

    describe ".not_in_active_transmission" do
      it "scopes on reports out of an active transmission" do
        expect {
          described_class.not_in_active_transmission.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."transmission_id" IS NULL
        SQL
      end
    end

    describe ".in_transmission" do
      let(:transmission) { create(:transmission) }

      it "scopes on reports in a given transmission" do
        expect {
          described_class.in_transmission(transmission).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."transmission_id" = '#{transmission.id}'
        SQL
      end
    end

    describe ".not_in_transmission" do
      let(:transmission) { create(:transmission) }

      it "scopes on reports not in a given transmission" do
        expect {
          described_class.not_in_transmission(transmission).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  (
                 "reports"."transmission_id" != '#{transmission.id}'
            OR   "reports"."transmission_id" IS NULL
          )
        SQL
      end

      it "is mergeable with another scope" do
        expect {
          described_class.ready.not_in_transmission(transmission).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'ready'
            AND  (
                       "reports"."transmission_id" != '#{transmission.id}'
                    OR "reports"."transmission_id" IS NULL
                 )
        SQL
      end
    end

    describe ".made_through_publisher_api" do
      it "scopes on reports made through API" do
        expect {
          described_class.made_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".made_through_web_ui" do
      it "scopes on reports made through Web UI" do
        expect {
          described_class.made_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".made_by_collectivity" do
      it "scopes on reports made by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.made_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on reports made by many collectivities" do
        expect {
          described_class.made_by_collectivity(Collectivity.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."collectivity_id" IN (
            SELECT "collectivities"."id"
            FROM   "collectivities"
            WHERE  "collectivities"."name" = 'A'
          )
        SQL
      end
    end

    describe ".made_by_publisher" do
      it "scopes on reports made by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.made_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on reports made by many publishers" do
        expect {
          described_class.made_by_publisher(Publisher.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IN (
            SELECT "publishers"."id"
            FROM   "publishers"
            WHERE  "publishers"."name" = 'A'
          )
        SQL
      end
    end

    describe ".transmitted_to_ddfip" do
      it "scopes reports transmitted to a DDFIP" do
        ddfip = create(:ddfip)

        expect {
          described_class.transmitted_to_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled', 'rejected')
            AND      "reports"."ddfip_id" = '#{ddfip.id}'
        SQL
      end
    end

    describe ".assigned_to_office" do
      it "scopes reports assigned to Office" do
        office = create(:office)

        expect {
          described_class.assigned_to_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('assigned', 'applicable', 'inapplicable', 'approved', 'canceled')
            AND      "reports"."office_id" = '#{office.id}'
        SQL
      end
    end

    describe ".covered_by_ddfip" do
      it "scopes reports covered by one single DDFIP" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.covered_by_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "communes"."code_departement" = '64'
        SQL
      end

      it "scopes reports covered by many DDFIPs" do
        expect {
          described_class.covered_by_ddfip(DDFIP.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "communes"."code_departement" IN (
            SELECT "ddfips"."code_departement"
            FROM   "ddfips"
            WHERE  "ddfips"."name" = 'A'
          )
        SQL
      end
    end

    describe ".covered_by_office" do
      it "scopes reports covered by one single office" do
        office = create(:office, :evaluation_local_habitation)

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT      DISTINCT "reports".*
          FROM        "reports"
          INNER JOIN  "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          INNER JOIN  "offices" ON  "offices"."id" = "office_communes"."office_id"
                                AND "reports"."form_type" = ANY ("offices"."competences")
          WHERE       "offices"."id" = '#{office.id}'
        SQL
      end

      it "scopes reports covered by many offices" do
        expect {
          described_class.covered_by_office(Office.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT      DISTINCT "reports".*
          FROM        "reports"
          INNER JOIN  "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          INNER JOIN  "offices" ON  "offices"."id" = "office_communes"."office_id"
                                AND "reports"."form_type" = ANY ("offices"."competences")
          WHERE       "offices"."id" IN (
                        SELECT "offices"."id"
                        FROM   "offices"
                        WHERE  "offices"."name" = 'A'
                      )
        SQL
      end
    end
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for reports with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE (
                      "reports"."reference" = 'Hello'
                  OR  "reports"."situation_invariant" = 'Hello'
                  OR  "reports"."package_id" IN (SELECT "packages"."id" FROM "packages" WHERE "packages"."reference" = 'Hello')
                  OR  LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%'))
                  OR  LOWER(UNACCENT("reports"."computed_address")) LIKE LOWER(UNACCENT('%Hello%'))
                )
        SQL
      end

      it "searches for reports by matching invariant" do
        expect {
          described_class.search(invariant: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."situation_invariant" = 'Hello'
        SQL
      end

      it "searches for reports by matching reference" do
        expect {
          described_class.search(reference: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."reference" = 'Hello'
        SQL
      end

      it "searches for reports by matching package reference" do
        expect {
          described_class.search(package: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."package_id" IN (SELECT "packages"."id" FROM "packages" WHERE "packages"."reference" = 'Hello')
        SQL
      end

      it "searches for reports by matching commune name" do
        expect {
          described_class.search(commune: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE           (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for reports by matching address" do
        expect {
          described_class.search(address: " 2   rue des arbres  ").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  (LOWER(UNACCENT("reports"."computed_address")) LIKE LOWER(UNACCENT('%2 rue des arbres%')))
        SQL
      end

      it "searches for reports by matching form_type" do
        expect {
          described_class.search(form_type: %w[evaluation_local_professionnel creation_local_professionnel]).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" IN ('evaluation_local_professionnel', 'creation_local_professionnel')
        SQL
      end

      it "searches for reports by matching anomalies" do
        expect {
          described_class.search(anomalies: "omission_batie").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  ('omission_batie' = ANY ("reports"."anomalies"))
        SQL
      end

      it "searches for reports by priority" do
        expect {
          described_class.search(priority: "high").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."priority" = 'high'
        SQL
      end

      it "searches for reports by collectivity name" do
        expect {
          described_class.search(collectivity: "Pays Basque").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "collectivities" ON "collectivities"."id" = "reports"."collectivity_id"
          WHERE           (LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Pays Basque%')))
        SQL
      end

      it "searches for reports by DDFIP name" do
        expect {
          described_class.search(ddfip: "Pyrénées").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "reports"."ddfip_id"
          WHERE           (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Pyrénées%')))
        SQL
      end

      it "searches for reports by office name" do
        expect {
          described_class.search(office: "SDIF").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "offices" ON "offices"."id" = "reports"."office_id"
          WHERE           (LOWER(UNACCENT("offices"."name")) LIKE LOWER(UNACCENT('%SDIF%')))
        SQL
      end
    end

    describe ".search_by_state" do
      it "searches for reports matching given value" do
        expect {
          described_class.search_by_state("transmitted").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'transmitted'
        SQL
      end

      it "searches for reports matching multiple values, excluding unknown values" do
        expect {
          described_class.search_by_state(%w[transmitted foo assigned]).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" IN ('transmitted', 'assigned')
        SQL
      end

      it "returns a null relation when none of the enum match the given value" do
        expect(
          described_class.search_by_state("Hello")
        ).to be_a_null_relation
      end

      it "returns a null relation when none of the enum match all the given values" do
        expect(
          described_class.search_by_state(%w[Foo Bar])
        ).to be_a_null_relation
      end
    end

    describe ".search_by_form_type" do
      it "searches for reports matching given value" do
        expect {
          described_class.search_by_form_type("evaluation_local_professionnel").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" = 'evaluation_local_professionnel'
        SQL
      end

      it "searches for reports matching multiple values, excluding unknown values" do
        expect {
          described_class.search_by_form_type(%w[evaluation_local_professionnel evaluation_local_habitation destruction_local_professionnel]).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" IN ('evaluation_local_professionnel', 'evaluation_local_habitation')
        SQL
      end

      it "returns a null relation when none of the enum match the given value" do
        expect(
          described_class.search_by_form_type("Hello")
        ).to be_a_null_relation
      end

      it "returns a null relation when none of the enum match all the given values" do
        expect(
          described_class.search_by_form_type(%w[Foo Bar])
        ).to be_a_null_relation
      end
    end

    describe ".search_by_anomalies" do
      it "searches for reports matching given value" do
        expect {
          described_class.search_by_anomalies("omission_batie").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  ('omission_batie' = ANY ("reports"."anomalies"))
        SQL
      end

      it "searches for reports matching multiple values, excluding unknown values" do
        expect {
          described_class.search_by_anomalies(%w[consistance categorie foo]).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  ("reports"."anomalies" && ARRAY['consistance'::anomaly, 'categorie'::anomaly])
        SQL
      end

      it "returns a null relation when none of the enum match the given value" do
        expect(
          described_class.search_by_anomalies("Hello")
        ).to be_a_null_relation
      end

      it "returns a null relation when none of the enum match all the given values" do
        expect(
          described_class.search_by_anomalies(%w[Foo Bar])
        ).to be_a_null_relation
      end
    end

    describe ".search_by_priority" do
      it "searches for reports matching given value" do
        expect {
          described_class.search_by_priority("high").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."priority" = 'high'
        SQL
      end

      it "searches for reports matching multiple values, excluding unknown values" do
        expect {
          described_class.search_by_priority(%w[low medium]).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."priority" IN ('low', 'medium')
        SQL
      end

      it "returns a null relation when none of the enum match the given value" do
        expect(
          described_class.search_by_priority("Hello")
        ).to be_a_null_relation
      end

      it "returns a null relation when none of the enum match all the given values" do
        expect(
          described_class.search_by_priority(%w[Foo Bar])
        ).to be_a_null_relation
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts reports by invariant" do
        expect {
          described_class.order_by_param("invariant").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."situation_invariant" ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by invariant in reversed order" do
        expect {
          described_class.order_by_param("-invariant").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."situation_invariant" DESC,
                    "reports"."created_at" DESC
        SQL
      end

      it "sorts reports by priority" do
        expect {
          described_class.order_by_param("priority").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."priority" ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by priority in reversed order" do
        expect {
          described_class.order_by_param("-priority").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."priority" DESC,
                    "reports"."created_at" DESC
        SQL
      end

      it "sorts reports by reference" do
        expect {
          described_class.order_by_param("reference").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."reference" ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by reference in reversed order" do
        expect {
          described_class.order_by_param("-reference").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."reference" DESC,
                    "reports"."created_at" DESC
        SQL
      end

      it "orders reports by state" do
        expect {
          described_class.order_by_param("state").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."state" ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "orders reports by state in reversed order" do
        expect {
          described_class.order_by_param("-state").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."state" DESC,
                    "reports"."created_at" DESC
        SQL
      end

      it "sorts reports by form type" do
        expect {
          described_class.order_by_param("form_type").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          WHERE     "reports"."form_type" IN ('creation_local_habitation', 'creation_local_professionnel', 'evaluation_local_habitation', 'evaluation_local_professionnel', 'occupation_local_habitation', 'occupation_local_professionnel')
          ORDER BY  CASE
                    WHEN "reports"."form_type" = 'creation_local_habitation'      THEN 1
                    WHEN "reports"."form_type" = 'creation_local_professionnel'   THEN 2
                    WHEN "reports"."form_type" = 'evaluation_local_habitation'    THEN 3
                    WHEN "reports"."form_type" = 'evaluation_local_professionnel' THEN 4
                    WHEN "reports"."form_type" = 'occupation_local_habitation'    THEN 5
                    WHEN "reports"."form_type" = 'occupation_local_professionnel' THEN 6
                    END ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by form type in reversed order" do
        expect {
          described_class.order_by_param("-form_type").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          WHERE     "reports"."form_type" IN ('occupation_local_professionnel', 'occupation_local_habitation', 'evaluation_local_professionnel', 'evaluation_local_habitation', 'creation_local_professionnel', 'creation_local_habitation')
          ORDER BY  CASE
                    WHEN "reports"."form_type" = 'occupation_local_professionnel' THEN 1
                    WHEN "reports"."form_type" = 'occupation_local_habitation'    THEN 2
                    WHEN "reports"."form_type" = 'evaluation_local_professionnel' THEN 3
                    WHEN "reports"."form_type" = 'evaluation_local_habitation'    THEN 4
                    WHEN "reports"."form_type" = 'creation_local_professionnel'   THEN 5
                    WHEN "reports"."form_type" = 'creation_local_habitation'      THEN 6
                    END ASC,
                    "reports"."created_at" DESC
        SQL
      end

      it "orders reports by anomalies" do
        expect {
          described_class.order_by_param("anomalies").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  CASE
                    WHEN "anomalies"[1] = 'correctif'          THEN 1
                    WHEN "anomalies"[1] = 'adresse'            THEN 2
                    WHEN "anomalies"[1] = 'affectation'        THEN 3
                    WHEN "anomalies"[1] = 'categorie'          THEN 4
                    WHEN "anomalies"[1] = 'consistance'        THEN 5
                    WHEN "anomalies"[1] = 'construction_neuve' THEN 6
                    WHEN "anomalies"[1] = 'exoneration'        THEN 7
                    WHEN "anomalies"[1] = 'occupation'         THEN 8
                    WHEN "anomalies"[1] = 'omission_batie'     THEN 9
                    ELSE 10
                    END ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "orders reports by anomalies in reversed order" do
        expect {
          described_class.order_by_param("-anomalies").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  CASE
                    WHEN "anomalies"[1] = 'omission_batie'     THEN 1
                    WHEN "anomalies"[1] = 'occupation'         THEN 2
                    WHEN "anomalies"[1] = 'exoneration'        THEN 3
                    WHEN "anomalies"[1] = 'construction_neuve' THEN 4
                    WHEN "anomalies"[1] = 'consistance'        THEN 5
                    WHEN "anomalies"[1] = 'categorie'          THEN 6
                    WHEN "anomalies"[1] = 'affectation'        THEN 7
                    WHEN "anomalies"[1] = 'adresse'            THEN 8
                    WHEN "anomalies"[1] = 'correctif'          THEN 9
                    ELSE 0
                    END ASC,
                    "reports"."created_at" DESC
        SQL
      end

      it "sorts reports by address" do
        expect {
          described_class.order_by_param("adresse").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."computed_address_sort_key" ASC,
                    "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by address in reversed order" do
        expect {
          described_class.order_by_param("-adresse").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "reports".*
          FROM      "reports"
          ORDER BY  "reports"."computed_address_sort_key" DESC,
                    "reports"."created_at" DESC
        SQL
      end

      it "sorts reports by commune" do
        expect {
          described_class.order_by_param("commune").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          ORDER BY        REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') ASC NULLS LAST,
                          "reports"."created_at" ASC
        SQL
      end

      it "sorts reports by commune in reversed order" do
        expect {
          described_class.order_by_param("-commune").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "reports".*
          FROM            "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          ORDER BY        REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') DESC NULLS FIRST,
                          "reports"."created_at" DESC
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    let_it_be(:publisher)      { build_stubbed(:publisher) }
    let_it_be(:collectivities) { build_stubbed_list(:collectivity, 2, publisher: publisher) }
    let_it_be(:departement) { create(:departement, code_departement: "64") }
    let_it_be(:ddfip) { create(:ddfip, departement: departement) }
    let_it_be(:commune) { create(:commune, departement: departement) }

    let_it_be(:reports) do
      collectivity = collectivities[0]

      {
        draft:                             build_stubbed(:report, :draft, collectivity:, commune:),
        ready:                             build_stubbed(:report, :ready, collectivity:, commune:),
        transmitting_through_web_ui:       build_stubbed(:report, :in_active_transmission, :made_through_web_ui, collectivity:),
        transmitting_through_api:          build_stubbed(:report, :in_active_transmission, :made_through_api, collectivity:, publisher:),
        transmitting_to_sandbox:           build_stubbed(:report, :in_active_transmission, :made_through_api, :sandbox, collectivity:, publisher:),
        transmitted_through_web_ui:        build_stubbed(:report, :transmitted_through_web_ui, collectivity:),
        transmitted_through_api:           build_stubbed(:report, :transmitted_through_api, collectivity:, publisher:),
        transmitted_to_sandbox:            build_stubbed(:report, :transmitted_to_sandbox, collectivity:, publisher:),
        acknowledged:                      build_stubbed(:report, :acknowledged, collectivity:),
        accepted:                          build_stubbed(:report, :accepted, collectivity:),
        assigned:                          build_stubbed(:report, :assigned, collectivity:),
        applicable:                        build_stubbed(:report, :applicable, collectivity:),
        inapplicable:                      build_stubbed(:report, :inapplicable, collectivity:),
        approved:                          build_stubbed(:report, :approved, collectivity:),
        canceled:                          build_stubbed(:report, :canceled, collectivity:),
        rejected:                          build_stubbed(:report, :rejected, collectivity:),
        from_another_collectivity:         build_stubbed(:report, collectivity: collectivities[1]),
        unsaved:                           build(:report, collectivity:),
        unsaved_from_api:                  build(:report, :made_through_api, collectivity:, publisher:),
        unsaved_from_another_collectivity: build(:report, collectivity: collectivities[1])
      }
    end

    describe "#covered_by_ddfip?" do
      it { expect(reports[:draft])                      .to     be_covered_by_ddfip(ddfip) }
      it { expect(reports[:ready])                      .to     be_covered_by_ddfip(ddfip) }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_covered_by_ddfip(ddfip) }
      it { expect(reports[:transmitting_through_api])   .not_to be_covered_by_ddfip(ddfip) }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_covered_by_ddfip(ddfip) }
    end

    describe "#covered_by_office?" do
      let(:office) { create(:office, competences: Report::FORM_TYPES.dup, ddfip:, communes: [commune]) }

      it { expect(reports[:draft])                      .to     be_covered_by_office(office) }
      it { expect(reports[:ready])                      .to     be_covered_by_office(office) }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_covered_by_office(office) }
      it { expect(reports[:transmitting_through_api])   .not_to be_covered_by_office(office) }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_covered_by_office(office) }
    end

    describe "#covered_by_offices?" do
      let(:offices) { create_list(:office, 3, ddfip:) }

      before { reports[:assigned].office = offices[2] }

      it { expect(reports[:draft])                      .not_to be_covered_by_offices(offices) }
      it { expect(reports[:assigned])                   .to     be_covered_by_offices(offices) }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_covered_by_offices(offices) }
      it { expect(reports[:transmitting_through_api])   .not_to be_covered_by_offices(offices) }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_covered_by_offices(offices) }
    end

    describe "#out_of_sandbox?" do
      it { expect(reports[:draft])                      .to     be_out_of_sandbox }
      it { expect(reports[:ready])                      .to     be_out_of_sandbox }
      it { expect(reports[:transmitting_through_web_ui]).to     be_out_of_sandbox }
      it { expect(reports[:transmitting_through_api])   .to     be_out_of_sandbox }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_out_of_sandbox }
      it { expect(reports[:transmitted_through_web_ui]) .to     be_out_of_sandbox }
      it { expect(reports[:transmitted_through_api])    .to     be_out_of_sandbox }
    end

    describe "#made_through_publisher_api?" do
      it { expect(reports[:transmitting_through_web_ui]).not_to be_made_through_publisher_api }
      it { expect(reports[:transmitting_through_api])   .to     be_made_through_publisher_api }
      it { expect(reports[:transmitting_to_sandbox])    .to     be_made_through_publisher_api }
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_made_through_publisher_api }
      it { expect(reports[:transmitted_through_api])    .to     be_made_through_publisher_api }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_made_through_publisher_api }
      it { expect(reports[:unsaved])                    .not_to be_made_through_publisher_api }
      it { expect(reports[:unsaved_from_api])           .to     be_made_through_publisher_api }
    end

    describe "#made_through_web_ui?" do
      it { expect(reports[:transmitting_through_web_ui]).to     be_made_through_web_ui }
      it { expect(reports[:transmitting_through_api])   .not_to be_made_through_web_ui }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_made_through_web_ui }
      it { expect(reports[:transmitted_through_web_ui]) .to     be_made_through_web_ui }
      it { expect(reports[:transmitted_through_api])    .not_to be_made_through_web_ui }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_made_through_web_ui }
      it { expect(reports[:unsaved])                    .to     be_made_through_web_ui }
      it { expect(reports[:unsaved_from_api])           .not_to be_made_through_web_ui }
    end

    describe "#made_by_collectivity?" do
      it { expect(reports[:transmitting_through_web_ui])      .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:transmitting_through_api])         .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:transmitting_to_sandbox])          .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:transmitted_through_web_ui])       .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:transmitted_through_api])          .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:transmitted_to_sandbox])           .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:from_another_collectivity])        .not_to be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:unsaved])                          .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:unsaved_from_api])                 .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:unsaved_from_another_collectivity]).not_to be_made_by_collectivity(collectivities[0]) }
    end

    describe "#made_by_publisher?" do
      it { expect(reports[:transmitting_through_web_ui])      .not_to be_made_by_publisher(publisher) }
      it { expect(reports[:transmitting_through_api])         .to     be_made_by_publisher(publisher) }
      it { expect(reports[:transmitting_to_sandbox])          .to     be_made_by_publisher(publisher) }
      it { expect(reports[:transmitted_through_web_ui])       .not_to be_made_by_publisher(publisher) }
      it { expect(reports[:transmitted_through_api])          .to     be_made_by_publisher(publisher) }
      it { expect(reports[:transmitted_to_sandbox])           .to     be_made_by_publisher(publisher) }
      it { expect(reports[:from_another_collectivity])        .not_to be_made_by_publisher(publisher) }
      it { expect(reports[:unsaved])                          .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:unsaved_from_api])                 .to     be_made_by_collectivity(collectivities[0]) }
      it { expect(reports[:unsaved_from_another_collectivity]).not_to be_made_by_collectivity(collectivities[0]) }
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe "#anomalies=" do
      it "assigns the arrray passed as argument" do
        expect(
          Report.new(anomalies: %w[consistance adresse])
        ).to have_attributes(anomalies: %w[consistance adresse])
      end

      it "removes blank values from array" do
        expect(
          Report.new(anomalies: ["", "consistance", "adresse"])
        ).to have_attributes(anomalies: %w[consistance adresse])
      end

      it "maintains default Rails behavior when assigning non-array values" do
        expect(
          Report.new(anomalies: "consistance adresse")
        ).to have_attributes(anomalies: [])
      end
    end
  end

  # Database foreign keys & constraints
  # ----------------------------------------------------------------------------
  describe "database foreign keys" do
    it "nullifies transmission_id when transmission is deleted" do
      report = create(:report, :transmitted)

      transmission = Transmission.find(report.transmission_id)
      transmission.delete

      expect { report.reload }.to change(report, :transmission_id).to(nil)
    end
  end

  describe "database constraints" do
    let(:report) { create(:report) }

    it "asserts a form_type is allowed by not triggering DB constraints" do
      expect { report.update_columns(form_type: "evaluation_local_habitation") }
        .not_to raise_error
    end

    it "asserts a form_type is not allowed by triggering DB constraints" do
      expect { report.update_columns(form_type: "foo") }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end

    it "asserts a priority is allowed by not triggering DB constraints" do
      expect { report.update_columns(priority: "high") }
        .not_to raise_error
    end

    it "asserts a priority is not allowed by triggering DB constraints" do
      expect { report.update_columns(priority: "higher") }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end
  end
end
