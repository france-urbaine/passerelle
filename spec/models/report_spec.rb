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

    it { is_expected.to have_many(:potential_office_communes) }
    it { is_expected.to have_many(:potential_offices) }
    it { is_expected.to have_many(:offices) }

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

  # Constants
  describe "constants" do
    describe "SORTED_FORM_TYPES_BY_LABEL" do
      it do
        expect(Report::SORTED_FORM_TYPES_BY_LABEL).to eq({
          fr: %w[
            creation_local_habitation
            creation_local_professionnel
            evaluation_local_habitation
            evaluation_local_professionnel
            occupation_local_habitation
            occupation_local_professionnel
          ]
        })
      end
    end
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
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for reports with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE ("reports"."reference" = 'Hello'
          OR "reports"."situation_invariant" = 'Hello'
          OR "reports"."package_id" IN (SELECT "packages"."id" FROM "packages" WHERE "packages"."reference" = 'Hello')
          OR 1=0
          OR LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT(REPLACE(CONCAT(situation_adresse, ' ', situation_numero_voie, ' ', situation_indice_repetition, ' ', situation_libelle_voie ), ' ', ' '))) LIKE LOWER(UNACCENT('%Hello%')))
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
          described_class.search(package_reference: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."package_id" IN (SELECT "packages"."id" FROM "packages" WHERE "packages"."reference" = 'Hello')
        SQL
      end

      it "searches for reports by matching commune name" do
        expect {
          described_class.search(commune_name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE  (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for reports by matching address" do
        expect {
          described_class.search(address: " 2   rue des arbres  ").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  (LOWER(UNACCENT(REPLACE(CONCAT(situation_adresse, ' ', situation_numero_voie, ' ', situation_indice_repetition, ' ', situation_libelle_voie ), ' ', ' '))) LIKE LOWER(UNACCENT('%2 rue des arbres%')))
        SQL
      end

      it "searches for reports by matching form_type" do
        expect {
          described_class.search(form_type: "local prof").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" IN ('evaluation_local_professionnel', 'creation_local_professionnel', 'occupation_local_professionnel')
        SQL
      end
    end

    describe ".order_by_param" do
      it do
        expect {
          described_class.order_by_param("invariant").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          ORDER BY "reports"."situation_invariant" ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("priority").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          ORDER BY "reports"."priority" ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("reference").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          ORDER BY "reports"."reference" ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("adresse").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          ORDER BY CONCAT(situation_libelle_voie, situation_numero_voie, situation_indice_repetition, situation_adresse) ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("commune").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          LEFT OUTER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          ORDER BY UNACCENT("communes"."name") ASC NULLS FIRST, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("package").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          ORDER BY "reports"."reference" ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("form_type").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" IN ('creation_local_habitation', 'creation_local_professionnel', 'evaluation_local_habitation', 'evaluation_local_professionnel', 'occupation_local_habitation', 'occupation_local_professionnel')
          ORDER BY CASE
            WHEN "reports"."form_type" = 'creation_local_habitation' THEN 1
            WHEN "reports"."form_type" = 'creation_local_professionnel' THEN 2
            WHEN "reports"."form_type" = 'evaluation_local_habitation' THEN 3
            WHEN "reports"."form_type" = 'evaluation_local_professionnel' THEN 4
            WHEN "reports"."form_type" = 'occupation_local_habitation' THEN 5
            WHEN "reports"."form_type" = 'occupation_local_professionnel' THEN 6
            END ASC, "reports"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("-form_type").load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."form_type" IN ('occupation_local_professionnel', 'occupation_local_habitation', 'evaluation_local_professionnel', 'evaluation_local_habitation', 'creation_local_professionnel', 'creation_local_habitation')
          ORDER BY CASE
            WHEN "reports"."form_type" = 'occupation_local_professionnel' THEN 1
            WHEN "reports"."form_type" = 'occupation_local_habitation' THEN 2
            WHEN "reports"."form_type" = 'evaluation_local_professionnel' THEN 3
            WHEN "reports"."form_type" = 'evaluation_local_habitation' THEN 4
            WHEN "reports"."form_type" = 'creation_local_professionnel' THEN 5
            WHEN "reports"."form_type" = 'creation_local_habitation' THEN 6
            END ASC, "reports"."created_at" DESC
        SQL
      end
    end

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

    describe ".draft" do
      it "scopes reports with incomplete form" do
        expect {
          described_class.draft.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'draft'
        SQL
      end
    end

    describe ".ready" do
      it "scopes reports with completed form" do
        expect {
          described_class.ready.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'ready'
        SQL
      end
    end

    describe ".sent" do
      it "scopes reports sent to ddfip" do
        expect {
          described_class.sent.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'sent'
        SQL
      end
    end

    describe ".acknowledged" do
      it "scopes reports acknowledged by ddfip" do
        expect {
          described_class.acknowledged.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'acknowledged'
        SQL
      end
    end

    describe ".denied" do
      it "scopes reports denied by ddfip" do
        expect {
          described_class.denied.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'denied'
        SQL
      end
    end

    describe ".processing" do
      it "scopes reports processing by dgfip" do
        expect {
          described_class.processing.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'processing'
        SQL
      end
    end

    describe ".approved" do
      it "scopes reports approved by dgfip" do
        expect {
          described_class.approved.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'approved'
        SQL
      end
    end

    describe ".rejected" do
      it "scopes reports rejected by dgfip" do
        expect {
          described_class.rejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'rejected'
        SQL
      end
    end

    describe ".packing" do
      it "scopes reports not yet transmitted" do
        expect {
          described_class.packing.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" IN ('draft', 'ready')
        SQL
      end
    end

    describe ".unassigned" do
      it "scopes on unassigned report" do
        expect {
          described_class.unassigned.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('sent', 'acknowledged')
        SQL
      end
    end

    describe ".assigned" do
      it "scopes on assigned report" do
        expect {
          described_class.assigned.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('processing', 'approved', 'rejected')
        SQL
      end
    end

    describe ".unresolved" do
      it "scopes transmitted reports from unresolved packages" do
        expect {
          described_class.unresolved.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('sent', 'acknowledged', 'processing')
        SQL
      end
    end

    describe ".undenied" do
      it "scopes on reports approved ot rejected by the DDFIP" do
        expect {
          described_class.undenied.load
        }.to perform_sql_query(<<~SQL)
          SELECT      "reports".*
          FROM        "reports"
          WHERE       "reports"."state" IN ('sent', 'acknowledged', 'processing', 'approved', 'rejected')
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes transmitted reports" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          WHERE      "reports"."state" IN ('sent', 'acknowledged', 'denied', 'processing', 'approved', 'rejected')
        SQL
      end
    end

    describe ".resolved" do
      it "scopes on reports approved ot rejected by the DDFIP" do
        expect {
          described_class.resolved.load
        }.to perform_sql_query(<<~SQL)
          SELECT      "reports".*
          FROM        "reports"
          WHERE       "reports"."state" IN ('approved', 'rejected')
        SQL
      end
    end

    describe ".transmissible" do
      it "scopes on ready reports not yet transmitted" do
        expect {
          described_class.transmissible.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."state" = 'ready'
            AND  "reports"."transmission_id" IS NULL
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
          WHERE      "reports"."state" IN ('sent', 'acknowledged', 'denied', 'processing', 'approved', 'rejected')
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
          WHERE      "reports"."state" IN ('processing', 'approved', 'rejected')
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
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."form_type" = 'evaluation_local_habitation'
        SQL
      end

      it "scopes reports covered by one single office with multiple competences" do
        office = create(:office, competences: %w[evaluation_local_habitation evaluation_local_professionnel])

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."form_type" IN ('evaluation_local_habitation', 'evaluation_local_professionnel')
        SQL
      end

      it "scopes reports covered by many offices" do
        expect {
          described_class.covered_by_office(Office.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          INNER JOIN "offices" ON "offices"."id" = "office_communes"."office_id"
          WHERE      "offices"."name" = 'A'
            AND      ("reports"."form_type" = ANY ("offices"."competences"))
        SQL
      end
    end

    describe ".order_by_resolved_date" do
      it "orders reports by resolved date" do
        expect {
          described_class.order_by_resolved_date.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          ORDER BY   COALESCE("reports"."approved_at", "reports"."rejected_at") ASC
        SQL
      end

      it "orders reports by resolved date in reversed order" do
        expect {
          described_class.order_by_resolved_date(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          ORDER BY   COALESCE("reports"."approved_at", "reports"."rejected_at") DESC
        SQL
      end
    end

    describe ".order_by_last_transmission_date" do
      it "orders reports by latest date of examination" do
        expect {
          described_class.order_by_last_transmission_date.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          ORDER BY   "reports"."transmitted_at" DESC
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
        transmitted_to_sandbox:            build_stubbed(:report, :transmitted_through_api, :sandbox, collectivity:, publisher:),
        acknowledged:                      build_stubbed(:report, :transmitted, state: "acknowledged", collectivity:),
        assigned:                          build_stubbed(:report, :assigned, collectivity:),
        denied:                            build_stubbed(:report, :denied, collectivity:),
        approved:                          build_stubbed(:report, :approved, collectivity:),
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

    describe "#draft?" do
      it { expect(reports[:draft])                      .to     be_draft }
      it { expect(reports[:ready])                      .not_to be_draft }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_draft }
      it { expect(reports[:transmitting_through_api])   .not_to be_draft }
    end

    describe "#ready?" do
      it { expect(reports[:draft])                      .not_to be_ready }
      it { expect(reports[:ready])                      .to     be_ready }
      it { expect(reports[:transmitting_through_web_ui]).to     be_ready }
      it { expect(reports[:transmitting_through_api])   .to     be_ready }
    end

    describe "#sent?" do
      it { expect(reports[:draft])                      .not_to be_sent }
      it { expect(reports[:ready])                      .not_to be_sent }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_sent }
      it { expect(reports[:transmitting_through_api])   .not_to be_sent }
      it { expect(reports[:transmitted_through_api])    .to     be_sent }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_sent }
      it { expect(reports[:assigned])                   .not_to be_sent }
    end

    describe "#acknowledged?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_acknowledged }
      it { expect(reports[:transmitted_through_api])    .not_to be_acknowledged }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_acknowledged }
      it { expect(reports[:assigned])                   .not_to be_acknowledged }
      it { expect(reports[:denied])                     .not_to be_acknowledged }
      it { expect(reports[:approved])                   .not_to be_acknowledged }
      it { expect(reports[:rejected])                   .not_to be_acknowledged }
      it { expect(reports[:acknowledged])               .to     be_acknowledged }
    end

    describe "#processing?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_processing }
      it { expect(reports[:transmitted_through_api])    .not_to be_processing }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_processing }
      it { expect(reports[:assigned])                   .to     be_processing }
      it { expect(reports[:denied])                     .not_to be_processing }
      it { expect(reports[:approved])                   .not_to be_processing }
      it { expect(reports[:rejected])                   .not_to be_processing }
    end

    describe "#denied?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_denied }
      it { expect(reports[:transmitted_through_api])    .not_to be_denied }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_denied }
      it { expect(reports[:assigned])                   .not_to be_denied }
      it { expect(reports[:denied])                     .to     be_denied }
      it { expect(reports[:approved])                   .not_to be_denied }
      it { expect(reports[:rejected])                   .not_to be_denied }
    end

    describe "#approved?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_approved }
      it { expect(reports[:transmitted_through_api])    .not_to be_approved }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_approved }
      it { expect(reports[:assigned])                   .not_to be_approved }
      it { expect(reports[:denied])                     .not_to be_approved }
      it { expect(reports[:approved])                   .to     be_approved }
      it { expect(reports[:rejected])                   .not_to be_approved }
    end

    describe "#rejected?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_rejected }
      it { expect(reports[:transmitted_through_api])    .not_to be_rejected }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_rejected }
      it { expect(reports[:assigned])                   .not_to be_rejected }
      it { expect(reports[:denied])                     .not_to be_rejected }
      it { expect(reports[:approved])                   .not_to be_rejected }
      it { expect(reports[:rejected])                   .to     be_rejected }
    end

    describe "#packing?" do
      it { expect(reports[:draft])                      .to     be_packing }
      it { expect(reports[:ready])                      .to     be_packing }
      it { expect(reports[:transmitting_through_web_ui]).to     be_packing }
      it { expect(reports[:transmitting_through_api])   .to     be_packing }
      it { expect(reports[:transmitting_to_sandbox])    .to     be_packing }
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_packing }
      it { expect(reports[:transmitted_through_api])    .not_to be_packing }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_packing }
    end

    describe "#unassigned?" do
      it { expect(reports[:transmitted_through_web_ui]) .to     be_unassigned }
      it { expect(reports[:transmitted_through_api])    .to     be_unassigned }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_unassigned }
      it { expect(reports[:assigned])                   .not_to be_unassigned }
      it { expect(reports[:denied])                     .not_to be_unassigned }
      it { expect(reports[:approved])                   .not_to be_unassigned }
      it { expect(reports[:rejected])                   .not_to be_unassigned }
    end

    describe "#assigned?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_assigned }
      it { expect(reports[:transmitted_through_api])    .not_to be_assigned }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_assigned }
      it { expect(reports[:assigned])                   .to     be_assigned }
      it { expect(reports[:denied])                     .not_to be_assigned }
      it { expect(reports[:approved])                   .to     be_assigned }
      it { expect(reports[:rejected])                   .to     be_assigned }
    end

    describe "#unresolved?" do
      it { expect(reports[:transmitted_through_web_ui]) .to     be_unresolved }
      it { expect(reports[:transmitted_through_api])    .to     be_unresolved }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_unresolved }
      it { expect(reports[:assigned])                   .to     be_unresolved }
      it { expect(reports[:denied])                     .not_to be_unresolved }
      it { expect(reports[:approved])                   .not_to be_unresolved }
      it { expect(reports[:rejected])                   .not_to be_unresolved }
    end

    describe "#undenied?" do
      it { expect(reports[:transmitted_through_web_ui]) .to     be_undenied }
      it { expect(reports[:transmitted_through_api])    .to     be_undenied }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_undenied }
      it { expect(reports[:assigned])                   .to     be_undenied }
      it { expect(reports[:denied])                     .not_to be_undenied }
      it { expect(reports[:approved])                   .to     be_undenied }
      it { expect(reports[:rejected])                   .to     be_undenied }
    end

    describe "#transmitted?" do
      it { expect(reports[:draft])                      .not_to be_transmitted }
      it { expect(reports[:ready])                      .not_to be_transmitted }
      it { expect(reports[:transmitting_through_web_ui]).not_to be_transmitted }
      it { expect(reports[:transmitting_through_api])   .not_to be_transmitted }
      it { expect(reports[:transmitting_to_sandbox])    .not_to be_transmitted }
      it { expect(reports[:transmitted_through_web_ui]) .to     be_transmitted }
      it { expect(reports[:transmitted_through_api])    .to     be_transmitted }
      it { expect(reports[:transmitted_to_sandbox])     .to     be_transmitted }
      it { expect(reports[:assigned])                   .to     be_transmitted }
      it { expect(reports[:denied])                     .to     be_transmitted }
      it { expect(reports[:approved])                   .to     be_transmitted }
      it { expect(reports[:rejected])                   .to     be_transmitted }
    end

    describe "#resolved?" do
      it { expect(reports[:transmitted_through_web_ui]) .not_to be_resolved }
      it { expect(reports[:transmitted_through_api])    .not_to be_resolved }
      it { expect(reports[:transmitted_to_sandbox])     .not_to be_resolved }
      it { expect(reports[:assigned])                   .not_to be_resolved }
      it { expect(reports[:denied])                     .not_to be_resolved }
      it { expect(reports[:approved])                   .to     be_resolved }
      it { expect(reports[:rejected])                   .to     be_resolved }
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

    describe "#resume!" do
      it "updates a ready report to be `draft`" do
        report = create(:report, :ready)

        expect {
          report.resume!
        }.to ret(true)
          .and change(report, :state).to("draft")
          .and change(report, :ready_at).to(nil)
          .and change(report, :updated_at)
      end

      it "doesn't update an already draft report but keeps returning true" do
        report = create(:report, :draft)

        expect {
          report.resume!
        }.to ret(true)
          .and not_change(report, :state).from("draft")
          .and not_change(report, :ready_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already transmitted report" do
        report = create(:report, :transmitted)

        expect {
          report.resume!
        }.to ret(false)
          .and not_change(report, :state).from("sent")
          .and not_change(report, :ready_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#complete!" do
      it "updates a draft report to be `ready`" do
        report = create(:report)

        expect {
          report.complete!
        }.to ret(true)
          .and change(report, :state).to("ready")
          .and change(report, :ready_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "doesn't update an already ready report but keeps returning true" do
        report = create(:report, :ready)

        expect {
          report.complete!
        }.to ret(true)
          .and not_change(report, :state).from("ready")
          .and not_change(report, :ready_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already transmitted report" do
        report = create(:report, :transmitted)

        expect {
          report.complete!
        }.to ret(false)
          .and not_change(report, :state).from("sent")
          .and not_change(report, :ready_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#transmit!" do
      it "updates a report to be `sent`" do
        report = create(:report, :ready)

        expect {
          report.transmit!
        }.to ret(true)
          .and change(report, :state).to("sent")
          .and change(report, :transmitted_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "doesn't update an already transmitted report but keeps returning true" do
        report = create(:report, :transmitted)

        expect {
          report.transmit!
        }.to ret(true)
          .and not_change(report, :state).from("sent")
          .and not_change(report, :transmitted_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already acknowledged report" do
        report = create(:report, :acknowledged)

        expect {
          report.transmit!
        }.to ret(false)
          .and not_change(report, :state).from("acknowledged")
          .and not_change(report, :transmitted_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#acknowledge!" do
      it "updates a report to be `acknowledged`" do
        report = create(:report, :transmitted)

        expect {
          report.acknowledge!
        }.to ret(true)
          .and change(report, :state).to("acknowledged")
          .and change(report, :acknowledged_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "doesn't update an already acknowledged report but keeps returning true" do
        report = create(:report, :acknowledged)

        expect {
          report.acknowledge!
        }.to ret(true)
          .and not_change(report, :state).from("acknowledged")
          .and not_change(report, :acknowledged_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already assigned report" do
        report = create(:report, :assigned)

        expect {
          report.acknowledge!
        }.to ret(false)
          .and not_change(report, :state).from("processing")
          .and not_change(report, :acknowledged_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#assign!" do
      it "updates a report to be `processing'" do
        report = create(:report, :transmitted)

        expect {
          report.assign!
        }.to ret(true)
          .and change(report, :state).to("processing")
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :acknowledged_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "updates an acknowledged report but keep the acknowledged date" do
        report = create(:report, :acknowledged)

        expect {
          report.assign!
        }.to ret(true)
          .and change(report, :state).to("processing")
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :updated_at)
          .and not_change(report, :acknowledged_at)
      end

      it "updates a denied report" do
        report = create(:report, :denied)

        expect {
          report.assign!
        }.to ret(true)
          .and change(report, :state).to("processing")
          .and change(report, :denied_at).to(nil)
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "doesn't update an already assigned report but keeps returning true" do
        report = create(:report, :assigned)

        expect {
          report.assign!
        }.to ret(true)
          .and not_change(report, :state).from("processing")
          .and not_change(report, :assigned_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already resolved report" do
        report = create(:report, :approved)

        expect {
          report.assign!
        }.to ret(false)
          .and not_change(report, :state).from("approved")
          .and not_change(report, :assigned_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#unassign!" do
      it "updates an assigned report back to `acknowledged`" do
        report = create(:report, :assigned)

        expect {
          report.unassign!
        }.to ret(true)
          .and change(report, :state).to("acknowledged")
          .and change(report, :assigned_at).to(nil)
          .and change(report, :updated_at)
          .and not_change(report, :acknowledged_at)
      end
    end

    describe "#deny!" do
      it "updates a report to be `denied'" do
        report = create(:report, :transmitted)

        expect {
          report.deny!
        }.to ret(true)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and change(report, :acknowledged_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "updates an acknowledged report but keep the acknowledged date" do
        report = create(:report, :acknowledged)

        expect {
          report.deny!
        }.to ret(true)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and change(report, :updated_at)
          .and not_change(report, :acknowledged_at)
      end

      it "updates an assigned report" do
        report = create(:report, :assigned)

        expect {
          report.deny!
        }.to ret(true)
          .and change(report, :state).to("denied")
          .and change(report, :assigned_at).to(nil)
          .and change(report, :denied_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "doesn't update an already denied report but keeps returning true" do
        report = create(:report, :denied)

        expect {
          report.deny!
        }.to ret(true)
          .and not_change(report, :state).from("denied")
          .and not_change(report, :denied_at)
          .and not_change(report, :updated_at)
      end

      it "doesn't update an already resolved report" do
        report = create(:report, :approved)

        expect {
          report.deny!
        }.to ret(false)
          .and not_change(report, :state).from("approved")
          .and not_change(report, :denied_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#undeny!" do
      it "updates a denied report back to `acknowledged`" do
        report = create(:report, :denied)

        expect {
          report.undeny!
        }.to ret(true)
          .and change(report, :state).to("acknowledged")
          .and change(report, :denied_at).to(nil)
          .and change(report, :updated_at)
          .and not_change(report, :acknowledged_at)
      end
    end

    describe "#approve!" do
      it "updates a report to be `approved'" do
        report = create(:report, :assigned)

        expect {
          report.approve!
        }.to ret(true)
          .and change(report, :state).to("approved")
          .and change(report, :approved_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "updates an already rejected report" do
        report = create(:report, :rejected)

        expect {
          report.approve!
        }.to ret(true)
          .and change(report, :state).to("approved")
          .and change(report, :approved_at).to(be_present)
          .and change(report, :rejected_at).to(nil)
          .and change(report, :updated_at)
      end

      it "doesn't update an already approved report but keeps returning true" do
        report = create(:report, :approved)

        expect {
          report.approve!
        }.to ret(true)
          .and not_change(report, :state).from("approved")
          .and not_change(report, :approved_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#unapproved!" do
      it "updates an approved report back to `processing`" do
        report = create(:report, :approved)

        expect {
          report.unapprove!
        }.to ret(true)
          .and change(report, :state).to("processing")
          .and change(report, :approved_at).to(nil)
          .and change(report, :updated_at)
      end
    end

    describe "#reject!" do
      it "updates a report to be `rejected'" do
        report = create(:report, :assigned)

        expect {
          report.reject!
        }.to ret(true)
          .and change(report, :state).to("rejected")
          .and change(report, :rejected_at).to(be_present)
          .and change(report, :updated_at)
      end

      it "updates an approved report" do
        report = create(:report, :approved)

        expect {
          report.reject!
        }.to ret(true)
          .and change(report, :state).to("rejected")
          .and change(report, :rejected_at).to(be_present)
          .and change(report, :approved_at).to(nil)
          .and change(report, :updated_at)
      end

      it "doesn't update an already rejected report but keeps returning true" do
        report = create(:report, :rejected)

        expect {
          report.reject!
        }.to ret(true)
          .and not_change(report, :state).from("rejected")
          .and not_change(report, :rejected_at)
          .and not_change(report, :updated_at)
      end
    end

    describe "#unreject!" do
      it "updates a rejected report back to `processing`" do
        report = create(:report, :rejected)

        expect {
          report.unreject!
        }.to ret(true)
          .and change(report, :state).to("processing")
          .and change(report, :rejected_at).to(nil)
          .and change(report, :updated_at)
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
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
