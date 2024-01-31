# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivity do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:territory).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:transmissions) }
    it { is_expected.to have_many(:packages) }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }

    it { is_expected.to     allow_value("801453893") .for(:siren) }
    it { is_expected.not_to allow_value("1234567AB") .for(:siren) }
    it { is_expected.not_to allow_value("1234567891").for(:siren) }

    it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
    it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

    it { is_expected.to     allow_value("0123456789")        .for(:contact_phone) }
    it { is_expected.to     allow_value("123456789")         .for(:contact_phone) }
    it { is_expected.to     allow_value("01 23 45 67 89")    .for(:contact_phone) }
    it { is_expected.to     allow_value("+33 1 23 45 67 89") .for(:contact_phone) }
    it { is_expected.to     allow_value("+590 1 23 45 67 89").for(:contact_phone) }
    it { is_expected.not_to allow_value("01234567")          .for(:contact_phone) }
    it { is_expected.not_to allow_value("+44 1 23 45 67 89") .for(:contact_phone) }

    it { is_expected.to     allow_value("Commune")    .for(:territory_type) }
    it { is_expected.to     allow_value("EPCI")       .for(:territory_type) }
    it { is_expected.to     allow_value("Departement").for(:territory_type) }
    it { is_expected.not_to allow_value("DDFIP")      .for(:territory_type) }

    it "validates uniqueness of :siren & :name" do
      create(:collectivity)

      aggregate_failures do
        is_expected.to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "ignores discarded records when validating uniqueness of :siren & :name" do
      create(:collectivity, :discarded)

      aggregate_failures do
        is_expected.not_to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_collectivities = create_list(:collectivity, 2, :discarded)
      create(:collectivity, siren: discarded_collectivities[0].siren, name: discarded_collectivities[1].name)

      aggregate_failures do
        expect { discarded_collectivities[0].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
        expect { discarded_collectivities[1].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  # Normalization callbacks
  # ----------------------------------------------------------------------------
  describe "attribute normalization" do
    def build_record(...)
      user = build(:collectivity, ...)
      user.validate
      user
    end

    describe "#contact_phone" do
      it { expect(build_record(contact_phone: "0123456789")).to        have_attributes(contact_phone: "0123456789") }
      it { expect(build_record(contact_phone: "01 23 45 67 89")).to    have_attributes(contact_phone: "0123456789") }
      it { expect(build_record(contact_phone: "+33 1 23 45 67 89")).to have_attributes(contact_phone: "+33123456789") }
      it { expect(build_record(contact_phone: "")).to                  have_attributes(contact_phone: "") }
      it { expect(build_record(contact_phone: nil)).to                 have_attributes(contact_phone: nil) }
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".communes" do
      it "scopes collectivities which are a commune" do
        expect {
          described_class.communes.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."territory_type" = 'Commune'
        SQL
      end
    end

    describe ".epcis" do
      it "scopes collectivities which are an EPCI" do
        expect {
          described_class.epcis.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."territory_type" = 'EPCI'
        SQL
      end
    end

    describe ".departements" do
      it "scopes collectivities which are a departement" do
        expect {
          described_class.departements.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."territory_type" = 'Departement'
        SQL
      end
    end

    describe ".regions" do
      it "scopes collectivities which are a region" do
        expect {
          described_class.regions.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."territory_type" = 'Region'
        SQL
      end
    end

    describe ".orphans" do
      it "scopes collectivities without publisher" do
        expect {
          described_class.orphans.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".owned_by" do
      it "scopes collectivities owned by a publisher" do
        publisher = create(:publisher)

        expect {
          described_class.owned_by(publisher).load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" = '#{publisher.id}'
        SQL
      end
    end

    describe ".search" do
      it "searches for collectivities with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          LEFT OUTER JOIN "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
          WHERE (
                LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "collectivities"."siren" = 'Hello'
            OR  "publishers"."name" = 'Hello'
          )
        SQL
      end

      it "searches for collectivities by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  (LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for collectivities by matching SIREN" do
        expect {
          described_class.search(siren: "123456789").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."siren" = '123456789'
        SQL
      end

      it "searches for collectivities by matching publisher name" do
        expect {
          described_class.search(publisher_name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT          "collectivities".*
          FROM            "collectivities"
          LEFT OUTER JOIN "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
          WHERE           "publishers"."name" = 'Hello'
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for collectivities with text matching name or SIREN" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  (
                LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "collectivities"."siren" = 'Hello'
          )
        SQL
      end
    end

    describe ".order_by_param" do
      it "orders collectivities by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "collectivities".*
          FROM     "collectivities"
          ORDER BY UNACCENT("collectivities"."name") ASC,
                   "collectivities"."created_at" ASC
        SQL
      end

      it "orders collectivities by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "collectivities".*
          FROM     "collectivities"
          ORDER BY UNACCENT("collectivities"."name") DESC,
                   "collectivities"."created_at" DESC
        SQL
      end

      it "orders collectivities by SIREN" do
        expect {
          described_class.order_by_param("siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "collectivities".*
          FROM     "collectivities"
          ORDER BY "collectivities"."siren" ASC,
                   "collectivities"."created_at" ASC
        SQL
      end

      it "orders collectivities by SIREN in reversed order" do
        expect {
          described_class.order_by_param("-siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "collectivities".*
          FROM     "collectivities"
          ORDER BY "collectivities"."siren" DESC,
                   "collectivities"."created_at" DESC
        SQL
      end

      it "orders collectivities by publisher" do
        expect {
          described_class.order_by_param("publisher").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "collectivities".*
          FROM            "collectivities"
          LEFT OUTER JOIN "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
          ORDER BY        UNACCENT("publishers"."name") ASC NULLS FIRST,
                          "collectivities"."created_at" ASC
        SQL
      end

      it "orders collectivities by publisher in reversed order" do
        expect {
          described_class.order_by_param("-publisher").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "collectivities".*
          FROM            "collectivities"
          LEFT OUTER JOIN "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
          ORDER BY        UNACCENT("publishers"."name") DESC NULLS LAST,
                          "collectivities"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders communes by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "collectivities".*
          FROM     "collectivities"
          ORDER BY ts_rank_cd(to_tsvector('french', "collectivities"."name"), to_tsquery('french', 'Hello')) DESC,
                   "collectivities"."created_at" ASC
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    # Use only one publisher to reduce the number of queries and records to create
    let_it_be(:publisher) { build(:publisher) }
    let_it_be(:collectivities) do
      [
        build(:collectivity, :commune,     publisher: publisher),
        build(:collectivity, :epci,        publisher: publisher),
        build(:collectivity, :departement, publisher: publisher),
        build(:collectivity, :region,      publisher: publisher),
        build(:collectivity, :orphan)
      ]
    end

    describe "#orphan?" do
      it { expect(collectivities[0]).not_to be_orphan }
      it { expect(collectivities[1]).not_to be_orphan }
      it { expect(collectivities[2]).not_to be_orphan }
      it { expect(collectivities[3]).not_to be_orphan }
      it { expect(collectivities[4]).to be_orphan }
    end

    describe "#commune?" do
      it { expect(collectivities[0]).to be_commune }
      it { expect(collectivities[1]).not_to be_commune }
      it { expect(collectivities[2]).not_to be_commune }
      it { expect(collectivities[3]).not_to be_commune }
    end

    describe "#epci?" do
      it { expect(collectivities[0]).not_to be_epci }
      it { expect(collectivities[1]).to be_epci }
      it { expect(collectivities[2]).not_to be_epci }
      it { expect(collectivities[3]).not_to be_epci }
    end

    describe "#departement?" do
      it { expect(collectivities[0]).not_to be_departement }
      it { expect(collectivities[1]).not_to be_departement }
      it { expect(collectivities[2]).to be_departement }
      it { expect(collectivities[3]).not_to be_departement }
    end

    describe "#region?" do
      it { expect(collectivities[0]).not_to be_region }
      it { expect(collectivities[1]).not_to be_region }
      it { expect(collectivities[2]).not_to be_region }
      it { expect(collectivities[3]).to be_region }
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#reportable_communes" do
      subject(:reportable_communes) { collectivity.reportable_communes }

      context "when collectivity is a commune" do
        let(:collectivity) { build_stubbed(:collectivity, :commune) }

        it { expect(reportable_communes).to be_an(ActiveRecord::Relation) }
        it { expect(reportable_communes.model).to eq(Commune) }

        it "loads the commune matching the collectivity" do
          expect {
            reportable_communes.load
          }.to perform_sql_query(<<~SQL)
            SELECT "communes".*
            FROM   "communes"
            WHERE  (
              "communes"."id" IN (
                SELECT "communes"."id"
                FROM   "communes"
                WHERE  "communes"."id" = '#{collectivity.territory_id}'
                AND    "communes"."arrondissements_count" = 0
              )
              OR "communes"."code_insee_parent" IN (
                SELECT "communes"."code_insee"
                FROM   "communes"
                WHERE  "communes"."id" = '#{collectivity.territory_id}'
              )
            )
          SQL
        end
      end

      context "when collectivity is an EPCI" do
        let(:collectivity) { build_stubbed(:collectivity, :epci) }

        it { expect(reportable_communes).to be_an(ActiveRecord::Relation) }
        it { expect(reportable_communes.model).to eq(Commune) }

        it "loads the communes inside the EPCI" do
          expect {
            reportable_communes.load
          }.to perform_sql_query(<<~SQL)
            SELECT "communes".*
            FROM   "communes"
            WHERE  (
              "communes"."id" IN (
                SELECT     "communes"."id"
                FROM       "communes"
                INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
                WHERE      "epcis"."id" = '#{collectivity.territory_id}'
                  AND      "communes"."arrondissements_count" = 0
              )
              OR "communes"."code_insee_parent" IN (
                SELECT     "communes"."code_insee"
                FROM       "communes"
                INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
                WHERE      "epcis"."id" = '#{collectivity.territory_id}'
              )
            )
          SQL
        end
      end

      context "when collectivity is a Departement" do
        let(:collectivity) { build_stubbed(:collectivity, :departement) }

        it { expect(reportable_communes).to be_an(ActiveRecord::Relation) }
        it { expect(reportable_communes.model).to eq(Commune) }

        it "loads the communes inside the departement" do
          expect {
            reportable_communes.load
          }.to perform_sql_query(<<~SQL)
            SELECT "communes".*
            FROM   "communes"
            WHERE  (
              "communes"."id" IN (
                SELECT     "communes"."id"
                FROM       "communes"
                INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                WHERE      "departements"."id" = '#{collectivity.territory_id}'
                  AND      "communes"."arrondissements_count" = 0
              )
              OR "communes"."code_insee_parent" IN (
                SELECT     "communes"."code_insee"
                FROM       "communes"
                INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                WHERE      "departements"."id" = '#{collectivity.territory_id}'
              )
            )
          SQL
        end
      end

      context "when collectivity is a Region" do
        let(:collectivity) { build_stubbed(:collectivity, :region) }

        it { expect(reportable_communes).to be_an(ActiveRecord::Relation) }
        it { expect(reportable_communes.model).to eq(Commune) }

        it "loads the communes inside the region" do
          expect {
            reportable_communes.load
          }.to perform_sql_query(<<~SQL)
            SELECT "communes".*
            FROM   "communes"
            WHERE  (
              "communes"."id" IN (
                SELECT     "communes"."id"
                FROM       "communes"
                INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                INNER JOIN "regions"      ON "regions"."code_region" = "departements"."code_region"
                WHERE      "regions"."id" = '#{collectivity.territory_id}'
                  AND      "communes"."arrondissements_count" = 0
              )
              OR "communes"."code_insee_parent" IN (
                SELECT     "communes"."code_insee"
                FROM       "communes"
                INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                INNER JOIN "regions"      ON "regions"."code_region" = "departements"."code_region"
                WHERE      "regions"."id" = '#{collectivity.territory_id}'
              )
            )
          SQL
        end
      end
    end

    describe "#assigned_offices" do
      subject(:assigned_offices) { collectivity.assigned_offices }

      context "when collectivity is a commune" do
        let(:collectivity) { build_stubbed(:collectivity, :commune) }

        it { expect(assigned_offices).to be_an(ActiveRecord::Relation) }
        it { expect(assigned_offices.model).to eq(Office) }

        it "loads the commune matching the collectivity" do
          expect {
            assigned_offices.load
          }.to perform_sql_query(<<~SQL)
            SELECT DISTINCT "offices".*
            FROM            "offices"
            INNER JOIN      "office_communes" ON "office_communes"."office_id" = "offices"."id"
            INNER JOIN      "communes"        ON "communes"."code_insee" = "office_communes"."code_insee"
            WHERE           "offices"."discarded_at" IS NULL
              AND           (
                "communes"."id" IN (
                  SELECT "communes"."id"
                  FROM   "communes"
                  WHERE  "communes"."id" = '#{collectivity.territory_id}'
                    AND "communes"."arrondissements_count" = 0
                ) OR  "communes"."code_insee_parent" IN (
                  SELECT "communes"."code_insee"
                  FROM   "communes"
                  WHERE  "communes"."id" = '#{collectivity.territory_id}'
                )
              )
          SQL
        end
      end

      context "when collectivity is an EPCI" do
        let(:collectivity) { build_stubbed(:collectivity, :epci) }

        it { expect(assigned_offices).to be_an(ActiveRecord::Relation) }
        it { expect(assigned_offices.model).to eq(Office) }

        it "loads the commune matching the collectivity" do
          expect {
            assigned_offices.load
          }.to perform_sql_query(<<~SQL)
            SELECT DISTINCT "offices".*
            FROM            "offices"
            INNER JOIN      "office_communes" ON "office_communes"."office_id" = "offices"."id"
            INNER JOIN      "communes"        ON "communes"."code_insee" = "office_communes"."code_insee"
            WHERE           "offices"."discarded_at" IS NULL
              AND           (
                "communes"."id" IN (
                  SELECT     "communes"."id"
                  FROM       "communes"
                  INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
                  WHERE      "epcis"."id" = '#{collectivity.territory_id}'
                    AND      "communes"."arrondissements_count" = 0
                )
                OR "communes"."code_insee_parent" IN (
                  SELECT     "communes"."code_insee"
                  FROM       "communes"
                  INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
                  WHERE      "epcis"."id" = '#{collectivity.territory_id}'
                )
              )
          SQL
        end
      end

      context "when collectivity is a departement" do
        let(:collectivity) { build_stubbed(:collectivity, :departement) }

        it { expect(assigned_offices).to be_an(ActiveRecord::Relation) }
        it { expect(assigned_offices.model).to eq(Office) }

        it "loads the commune matching the collectivity" do
          expect {
            assigned_offices.load
          }.to perform_sql_query(<<~SQL)
            SELECT DISTINCT "offices".*
            FROM            "offices"
            INNER JOIN      "office_communes" ON "office_communes"."office_id" = "offices"."id"
            INNER JOIN      "communes"        ON "communes"."code_insee" = "office_communes"."code_insee"
            WHERE           "offices"."discarded_at" IS NULL
              AND           (
                "communes"."id" IN (
                  SELECT     "communes"."id"
                  FROM       "communes"
                  INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                  WHERE      "departements"."id" = '#{collectivity.territory_id}'
                    AND      "communes"."arrondissements_count" = 0
                )
                OR "communes"."code_insee_parent" IN (
                  SELECT     "communes"."code_insee"
                  FROM       "communes"
                  INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                  WHERE      "departements"."id" = '#{collectivity.territory_id}'
                )
              )
          SQL
        end
      end

      context "when collectivity is a region" do
        let(:collectivity) { build_stubbed(:collectivity, :region) }

        it { expect(assigned_offices).to be_an(ActiveRecord::Relation) }
        it { expect(assigned_offices.model).to eq(Office) }

        it "loads the commune matching the collectivity" do
          expect {
            assigned_offices.load
          }.to perform_sql_query(<<~SQL)
            SELECT DISTINCT "offices".*
            FROM            "offices"
            INNER JOIN      "office_communes" ON "office_communes"."office_id" = "offices"."id"
            INNER JOIN      "communes"        ON "communes"."code_insee" = "office_communes"."code_insee"
            WHERE           "offices"."discarded_at" IS NULL
              AND           (
                "communes"."id" IN (
                  SELECT     "communes"."id"
                  FROM       "communes"
                  INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                  INNER JOIN "regions"      ON "regions"."code_region" = "departements"."code_region"
                  WHERE      "regions"."id" = '#{collectivity.territory_id}'
                    AND      "communes"."arrondissements_count" = 0
                )
                OR "communes"."code_insee_parent" IN (
                  SELECT     "communes"."code_insee"
                  FROM       "communes"
                  INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                  INNER JOIN "regions"      ON "regions"."code_region" = "departements"."code_region"
                  WHERE      "regions"."id" = '#{collectivity.territory_id}'
                )
              )
          SQL
        end
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:publisher)      { create(:publisher, :with_users, users_size: 1) }
      let_it_be(:collectivities) { create_list(:collectivity, 2, publisher:) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_collectivities_counters()")
      end

      it "returns the number of concerned collectivities" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: collectivities[0])
          create_list(:user, 2, organization: collectivities[1])
          create(:user, :discarded, organization: collectivities[0])

          Collectivity.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.users_count }.to(4)
            .and change { collectivities[1].reload.users_count }.to(2)
        end
      end

      describe "reports counts" do
        before_all do
          collectivities[0].tap do |collectivity|
            create(:report, collectivity:)
            create(:report, :ready, collectivity:)
            create(:report, :sandbox, collectivity:, publisher:)
            create_list(:report, 2, :approved, collectivity:)
            create_list(:report, 3, :rejected, collectivity:)
          end

          collectivities[1].tap do |collectivity|
            create(:report, :denied, collectivity:)
          end

          Collectivity.update_all(
            reports_incomplete_count:  99,
            reports_packing_count:     99,
            reports_transmitted_count: 99,
            reports_denied_count:      99,
            reports_processing_count:  99,
            reports_approved_count:    99,
            reports_rejected_count:    99
          )
        end

        it "updates #reports_incomplete_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_incomplete_count }.to(1)
            .and change { collectivities[1].reload.reports_incomplete_count }.to(0)
        end

        it "updates #reports_packing_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_packing_count }.to(2)
            .and change { collectivities[1].reload.reports_packing_count }.to(0)
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_transmitted_count }.to(5)
            .and change { collectivities[1].reload.reports_transmitted_count }.to(1)
        end

        it "updates #reports_denied_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_denied_count }.to(0)
            .and change { collectivities[1].reload.reports_denied_count }.to(1)
        end

        it "updates #reports_processing_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_processing_count }.to(0)
            .and change { collectivities[1].reload.reports_processing_count }.to(0)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_approved_count }.to(2)
            .and change { collectivities[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { collectivities[0].reload.reports_rejected_count }.to(3)
            .and change { collectivities[1].reload.reports_rejected_count }.to(0)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of SIREN" do
      existing_collectivity = create(:collectivity)
      another_collectivity  = build(:collectivity, siren: existing_collectivity.siren)

      expect { another_collectivity.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "ignores discarded records when asserting the uniqueness of SIREN" do
      existing_collectivity = create(:collectivity, :discarded)
      another_collectivity  = build(:collectivity, siren: existing_collectivity.siren)

      expect { another_collectivity.save(validate: false) }
        .not_to raise_error
    end

    it "nullify the publisher_id of a collectivity after its publisher has been destroyed" do
      publisher    = create(:publisher)
      collectivity = create(:collectivity, publisher: publisher)

      expect {
        publisher.destroy
        collectivity.reload
      }.to change(collectivity, :publisher_id).to(nil)
    end
  end

  describe "database triggers" do
    let!(:collectivity) { create(:collectivity) }

    def create_user(*traits, **attributes)
      create(:user, *traits, organization: collectivity, **attributes)
    end

    def create_report(*traits, **attributes)
      create(:report, *traits, collectivity:, **attributes)
    end

    describe "#users_count" do
      it "changes on creation" do
        expect { create_user }
          .to change { collectivity.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user = create_user

        expect { user.delete }
          .to change { collectivity.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user = create_user

        expect { user.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user = create_user(:discarded)

        expect { user.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user = create_user
        another_collectivity = create(:collectivity)

        expect { user.update_columns(organization_id: another_collectivity.id) }
          .to change { collectivity.reload.users_count }.from(1).to(0)
      end
    end

    describe "#reports_incomplete_count" do
      it "changes when report is created" do
        expect { create_report }
          .to change { collectivity.reload.reports_incomplete_count }.from(0).to(1)
      end

      it "changes when report becomes ready" do
        report = create_report

        expect { report.update_columns(state: "ready") }
          .to change { collectivity.reload.reports_incomplete_count }.from(1).to(0)
      end

      it "changes when report becomes draft" do
        report = create_report(state: "ready")

        expect { report.update_columns(state: "draft") }
          .to change { collectivity.reload.reports_incomplete_count }.from(0).to(1)
      end

      it "changes when report is discarded" do
        report = create_report

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_incomplete_count }.from(1).to(0)
      end

      it "changes when report is sandboxed" do
        report = create_report

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_incomplete_count }.from(1).to(0)
      end

      it "changes when report is undiscarded" do
        report = create_report(:discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_incomplete_count }.from(0).to(1)
      end

      it "changes when report is deleted" do
        report = create_report

        expect { report.delete }
          .to change { collectivity.reload.reports_incomplete_count }.from(1).to(0)
      end
    end

    describe "#reports_packing_count" do
      it "changes when report is created" do
        expect { create_report }
          .to change { collectivity.reload.reports_packing_count }.from(0).to(1)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "sent") }
          .to change { collectivity.reload.reports_packing_count }.from(1).to(0)
      end

      it "changes when report is sandboxed" do
        report = create_report

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_packing_count }.from(1).to(0)
      end

      it "changes when report is discarded" do
        report = create_report

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_packing_count }.from(1).to(0)
      end

      it "changes when report is undiscarded" do
        report = create_report(:discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_packing_count }.from(0).to(1)
      end

      it "changes when report is deleted" do
        report = create_report

        expect { report.delete }
          .to change { collectivity.reload.reports_packing_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { collectivity.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "sent", transmitted_at: Time.current) }
          .to change { collectivity.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report = create_report

        expect { report.update_columns(state: "sent", transmitted_at: Time.current, sandbox: true) }
          .not_to change { collectivity.reload.reports_transmitted_count }.from(0)
      end

      it "changes when transmitted report is discarded" do
        report = create_report(:transmitted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report = create_report(:transmitted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report = create_report(:transmitted)

        expect { report.delete }
          .to change { collectivity.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_denied_count" do
      it "doesn't change when report are transmitted" do
        report = create_report

        expect { report.update_columns(state: "sent", transmitted_at: Time.current) }
          .not_to change { collectivity.reload.reports_denied_count }.from(0)
      end

      it "changes when report is returned" do
        report = create_report

        expect { report.update_columns(state: "denied") }
          .to change { collectivity.reload.reports_denied_count }.from(0).to(1)
      end

      it "doesn't change when report is assigned" do
        report = create_report

        expect { report.update_columns(state: "assigned") }
          .not_to change { collectivity.reload.reports_denied_count }.from(0)
      end

      it "changes when denied report is then assigned" do
        report = create_report(:denied)

        expect { report.update_columns(state: "assigned") }
          .to change { collectivity.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is sandboxed" do
        report = create_report(:denied)

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is discarded" do
        report = create_report(:denied)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is undiscarded" do
        report = create_report(:denied, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_denied_count }.from(0).to(1)
      end

      it "changes when denied report is deleted" do
        report = create_report(:denied)

        expect { report.delete }
          .to change { collectivity.reload.reports_denied_count }.from(1).to(0)
      end
    end

    describe "#reports_processing_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "sent", transmitted_at: Time.current) }
          .not_to change { collectivity.reload.reports_processing_count }.from(0)
      end

      it "changes when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "processing") }
          .to change { collectivity.reload.reports_processing_count }.from(0).to(1)
      end

      it "doesn't changes when report is denied" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "denied") }
          .not_to change { collectivity.reload.reports_processing_count }.from(0)
      end

      it "changes when assigned report is then denied" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "denied") }
          .to change { collectivity.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is approved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "approved") }
          .to change { collectivity.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when pending report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .to change { collectivity.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is sandboxed" do
        report = create_report(:assigned)

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is discarded" do
        report = create_report(:assigned)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is undiscarded" do
        report = create_report(:assigned, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_processing_count }.from(0).to(1)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { collectivity.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { collectivity.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "approved") }
          .to change { collectivity.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report = create_report(:approved)

        expect { report.update_columns(state: "processing") }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report = create_report(:approved)

        expect { report.update_columns(state: "rejected") }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is sandboxed" do
        report = create_report(:approved)

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is discarded" do
        report = create_report(:approved)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report = create_report(:approved, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_approved_count }.from(0).to(1)
      end
    end

    describe "#reports_rejected_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { collectivity.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "approved") }
          .not_to change { collectivity.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .to change { collectivity.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report = create_report(:rejected)

        expect { report.update_columns(state: "processing") }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report = create_report(:rejected)

        expect { report.update_columns(state: "apporved") }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is sandboxed" do
        report = create_report(:rejected)

        expect { report.update_columns(sandbox: true) }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is discarded" do
        report = create_report(:rejected)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report = create_report(:rejected, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { collectivity.reload.reports_rejected_count }.from(0).to(1)
      end
    end
  end
end
