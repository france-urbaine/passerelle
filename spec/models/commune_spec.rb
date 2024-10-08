# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe Commune do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:departement).required }
    it { is_expected.to belong_to(:epci).optional }
    it { is_expected.to have_one(:region).through(:departement) }

    it { is_expected.to belong_to(:commune).optional }
    it { is_expected.to respond_to(:arrondissements) }

    it { is_expected.to have_one(:registered_collectivity) }
    it { is_expected.to respond_to(:on_territory_collectivities) }

    it { is_expected.to have_many(:ddfips) }
    it { is_expected.to have_many(:offices).through(:office_communes) }
    it { is_expected.to have_many(:office_communes) }

    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code_insee) }
    it { is_expected.to validate_presence_of(:code_departement) }
    it { is_expected.not_to validate_presence_of(:siren_epci) }
    it { is_expected.not_to validate_presence_of(:code_insee_parent) }

    it { is_expected.to     allow_value("74123").for(:code_insee) }
    it { is_expected.to     allow_value("2A013").for(:code_insee) }
    it { is_expected.to     allow_value("97102").for(:code_insee) }
    it { is_expected.not_to allow_value("1A674").for(:code_insee) }
    it { is_expected.not_to allow_value("123456").for(:code_insee) }

    it { is_expected.to     allow_value("74123").for(:code_insee_parent) }
    it { is_expected.to     allow_value("2A013").for(:code_insee_parent) }
    it { is_expected.to     allow_value("97102").for(:code_insee_parent) }
    it { is_expected.not_to allow_value("1A674").for(:code_insee_parent) }
    it { is_expected.not_to allow_value("123456").for(:code_insee_parent) }

    it { is_expected.to     allow_value("01").for(:code_departement) }
    it { is_expected.to     allow_value("2A").for(:code_departement) }
    it { is_expected.to     allow_value("987").for(:code_departement) }
    it { is_expected.not_to allow_value("1").for(:code_departement) }
    it { is_expected.not_to allow_value("123").for(:code_departement) }
    it { is_expected.not_to allow_value("3C").for(:code_departement) }

    it { is_expected.to     allow_value("801453893").for(:siren_epci) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren_epci) }
    it { is_expected.not_to allow_value("1234567891").for(:siren_epci) }

    it "validates uniqueness of :code_insee" do
      create(:commune)
      is_expected.to validate_uniqueness_of(:code_insee).ignoring_case_sensitivity
    end
  end

  # Normalization callbacks
  # ----------------------------------------------------------------------------
  describe "attribute normalization" do
    # Create only one departement to reduce the number of queries and records to create
    let_it_be(:departement) { create(:departement) }

    def validate_record(**)
      build(:commune, departement:, **).tap(&:validate)
    end

    def create_record(**)
      create(:commune, departement:, **)
    end

    describe "#siren_epci" do
      it { expect(validate_record(siren_epci: "")).to  have_attributes(siren_epci: nil) }
      it { expect(validate_record(siren_epci: nil)).to have_attributes(siren_epci: nil) }
    end

    describe "#qualified_name" do
      it { expect(create_record(name: "Bayonne")).to     have_attributes(qualified_name: "Commune de Bayonne") }
      it { expect(create_record(name: "Le Chateley")).to have_attributes(qualified_name: "Commune du Chateley") }
      it { expect(create_record(name: "La Rochelle")).to have_attributes(qualified_name: "Commune de la Rochelle") }
      it { expect(create_record(name: "Les Arcs")).to    have_attributes(qualified_name: "Commune des Arcs") }
      it { expect(create_record(name: "L'Hermitage")).to have_attributes(qualified_name: "Commune de L'Hermitage") }
      it { expect(create_record(name: "Labbeville")).to  have_attributes(qualified_name: "Commune de Labbeville") }
      it { expect(create_record(name: "Avensan")) .to    have_attributes(qualified_name: "Commune d'Avensan") }
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".arrondissements" do
      it "scopes communes that are arrondissements" do
        expect {
          described_class.arrondissements.load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee_parent" IS NOT NULL
        SQL
      end
    end

    describe ".arrondissements_from" do
      it "scopes arrondissements belonging to a commune" do
        commune = create(:commune)

        expect {
          described_class.arrondissements_from(commune).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee_parent" = '#{commune.code_insee}'
        SQL
      end

      it "scopes arrondissements belonging to a communes relation" do
        expect {
          described_class.arrondissements_from(Commune.where(code_departement: "13")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee_parent" IN (
            SELECT "communes"."code_insee"
            FROM   "communes"
            WHERE  "communes"."code_departement" = '13'
          )
        SQL
      end
    end

    describe ".having_arrondissements" do
      it "scopes communes that have arrondissements" do
        expect {
          described_class.having_arrondissements.load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."arrondissements_count" >= 1
        SQL
      end
    end

    describe ".not_having_arrondissements" do
      it "scopes communes that have arrondissements" do
        expect {
          described_class.not_having_arrondissements.load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."arrondissements_count" = 0
        SQL
      end
    end

    describe ".with_arrondissements_instead_of_communes" do
      it "scopes all communes excluding those having arrondissements" do
        expect {
          Commune.with_arrondissements_instead_of_communes.load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."arrondissements_count" = 0
        SQL
      end

      it "scopes on given communes excluding those having arrondissements" do
        expect {
          Commune.with_arrondissements_instead_of_communes(Commune.where(code_departement: "13")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  (
            "communes"."id" IN (
              SELECT "communes"."id"
              FROM   "communes"
              WHERE  "communes"."code_departement" = '13'
                AND  "communes"."arrondissements_count" = 0
            )
            OR "communes"."code_insee_parent" IN (
              SELECT "communes"."code_insee"
              FROM   "communes"
              WHERE  "communes"."code_departement" = '13'
            )
          )
        SQL
      end

      it "is compatibles with scopes having joins" do
        expect {
          Commune.with_arrondissements_instead_of_communes(Commune.joins(:epci)).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  (
            "communes"."id" IN (
              SELECT     "communes"."id"
              FROM       "communes"
              INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
              WHERE      "communes"."arrondissements_count" = 0
            )
            OR "communes"."code_insee_parent" IN (
              SELECT     "communes"."code_insee"
              FROM       "communes"
              INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
            )
          )
        SQL
      end
    end

    describe ".covered_by_ddfip" do
      it "scopes communes covered by one single DDFIP" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.covered_by_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_departement" = '64'
        SQL
      end

      it "scopes communes covered by many DDFIPs" do
        expect {
          described_class.covered_by_ddfip(DDFIP.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_departement" IN (
            SELECT "ddfips"."code_departement"
            FROM   "ddfips"
            WHERE  "ddfips"."name" = 'A'
          )
        SQL
      end
    end

    describe ".covered_by_office" do
      it "scopes communes covered by one single office" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)
        office      = create(:office, ddfip: ddfip)

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee" IN (
            SELECT "office_communes"."code_insee"
            FROM   "office_communes"
            WHERE  "office_communes"."office_id" = '#{office.id}'
          )
        SQL
      end

      it "scopes communes covered by many offices" do
        expect {
          described_class.covered_by_office(Office.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee" IN (
            SELECT "office_communes"."code_insee"
            FROM   "office_communes"
            WHERE  "office_communes"."office_id" IN (
              SELECT "offices"."id"
              FROM   "offices"
              WHERE  "offices"."name" = 'A'
            )
          )
        SQL
      end
    end

    describe ".covered_by" do
      it "scopes communes covered by one single DDFIP" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.covered_by(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_departement" = '64'
        SQL
      end

      it "scopes communes covered by many DDFIPs" do
        expect {
          described_class.covered_by(DDFIP.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_departement" IN (
            SELECT "ddfips"."code_departement"
            FROM   "ddfips"
            WHERE  "ddfips"."name" = 'A'
          )
        SQL
      end

      it "scopes communes covered by one single office" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)
        office      = create(:office, ddfip: ddfip)

        expect {
          described_class.covered_by(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee" IN (
            SELECT "office_communes"."code_insee"
            FROM   "office_communes"
            WHERE  "office_communes"."office_id" = '#{office.id}'
          )
        SQL
      end

      it "scopes communes covered by many offices" do
        expect {
          described_class.covered_by(Office.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_insee" IN (
            SELECT "office_communes"."code_insee"
            FROM   "office_communes"
            WHERE  "office_communes"."office_id" IN (
              SELECT "offices"."id"
              FROM   "offices"
              WHERE  "offices"."name" = 'A'
            )
          )
        SQL
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.covered_by(User.all).load
        }.to raise_error(TypeError)
      end
    end
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for communes with all default criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (
                                (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                            OR  "communes"."code_insee" = 'Hello'
                            OR  "communes"."code_departement" = 'Hello'
                            OR  "communes"."siren_epci" = 'Hello'
                            OR  (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                            OR  (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                            OR  (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                          )
        SQL
      end

      it "searches for communes by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for communes by matching departement's code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  "communes"."code_departement" = '64'
        SQL
      end

      it "searches for communes by matching departement's name" do
        expect {
          described_class.search(departement_name: "Pyréne").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          WHERE           (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Pyréne%')))
        SQL
      end

      it "searches for communes by matching region's name" do
        expect {
          described_class.search(region_name: "Sud").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Sud%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for communes with text matching the qualified name and SIREN" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE (     (LOWER(UNACCENT("communes"."qualified_name")) LIKE LOWER(UNACCENT('%Hello%')))
                  OR  "communes"."code_insee" = 'Hello'
                )
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts communes by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') ASC NULLS LAST,
                   "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') DESC NULLS FIRST,
                   "communes"."code_insee" DESC
        SQL
      end

      it "sorts communes by code" do
        expect {
          described_class.order_by_param("code").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by code in reversed order" do
        expect {
          described_class.order_by_param("-code").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_insee" DESC
        SQL
      end

      it "sorts communes by departement" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_departement" ASC,
                   "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by departement in reversed order" do
        expect {
          described_class.order_by_param("-departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_departement" DESC,
                   "communes"."code_insee" DESC
        SQL
      end

      it "sorts communes by EPCI" do
        expect {
          described_class.order_by_param("epci").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY        UNACCENT("epcis"."name") ASC NULLS LAST,
                          "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by EPCI in reversed order" do
        expect {
          described_class.order_by_param("-epci").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY        UNACCENT("epcis"."name") DESC NULLS FIRST,
                          "communes"."code_insee" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts communes by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY ts_rank_cd(to_tsvector('french', "communes"."name"), to_tsquery('french', 'Hello')) DESC,
                   "communes"."code_insee" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts communes by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') ASC NULLS LAST
        SQL
      end

      it "sorts communes by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') ASC NULLS LAST
        SQL
      end

      it "sorts communes by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY REGEXP_REPLACE(UNACCENT("communes"."name"), '(^|[^0-9])([0-9])([^0-9])', '\\10\\2\\3') DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_code" do
      it "sorts communes by code INSEE without argument" do
        expect {
          described_class.order_by_code.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by code INSEE in ascending order" do
        expect {
          described_class.order_by_code(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_insee" ASC
        SQL
      end

      it "sorts communes by code INSEE in descending order" do
        expect {
          described_class.order_by_code(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_insee" DESC
        SQL
      end
    end

    describe ".order_by_departement" do
      it "sorts communes by departement's code without argument" do
        expect {
          described_class.order_by_departement.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_departement" ASC
        SQL
      end

      it "sorts communes by departement's code in ascending order" do
        expect {
          described_class.order_by_departement(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_departement" ASC
        SQL
      end

      it "sorts communes by departement's code in descending order" do
        expect {
          described_class.order_by_departement(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "communes".*
          FROM     "communes"
          ORDER BY "communes"."code_departement" DESC
        SQL
      end
    end

    describe ".order_by_epci" do
      it "sorts communes by EPCI's name without argument" do
        expect {
          described_class.order_by_epci.load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY        UNACCENT("epcis"."name") ASC NULLS LAST
        SQL
      end

      it "sorts communes by EPCI's name in ascending order" do
        expect {
          described_class.order_by_epci(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY        UNACCENT("epcis"."name") ASC NULLS LAST
        SQL
      end

      it "sorts communes by EPCI's name in descending order" do
        expect {
          described_class.order_by_epci(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "communes".*
          FROM            "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY        UNACCENT("epcis"."name") DESC NULLS FIRST
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { commune.on_territory_collectivities }

      context "without EPCI attached" do
        let(:commune) { create(:commune) }

        it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
        it { expect(on_territory_collectivities.model).to eq(Collectivity) }

        it "loads the registered collectivities having this commune in their territory" do
          expect {
            on_territory_collectivities.load
          }.to perform_sql_query(<<~SQL)
            SELECT "collectivities".*
            FROM   "collectivities"
            WHERE  "collectivities"."discarded_at" IS NULL
              AND  (
                      "collectivities"."territory_type" = 'Commune'
                  AND "collectivities"."territory_id"   = '#{commune.id}'
                  OR  "collectivities"."territory_type" = 'Departement'
                  AND "collectivities"."territory_id" IN (
                        SELECT "departements"."id"
                        FROM "departements"
                        WHERE "departements"."code_departement" = '#{commune.code_departement}'
                  )
              )
          SQL
        end
      end

      context "with an EPCI attached" do
        let(:commune) { create(:commune, :with_epci) }

        it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
        it { expect(on_territory_collectivities.model).to eq(Collectivity) }

        it "loads the registered collectivities having this commune in their territory" do
          expect {
            on_territory_collectivities.load
          }.to perform_sql_query(<<~SQL)
            SELECT "collectivities".*
            FROM   "collectivities"
            WHERE  "collectivities"."discarded_at" IS NULL
              AND (
                      "collectivities"."territory_type" = 'Commune'
                  AND "collectivities"."territory_id"   = '#{commune.id}'
                  OR  "collectivities"."territory_type" = 'EPCI'
                  AND "collectivities"."territory_id" IN (
                        SELECT "epcis"."id"
                        FROM "epcis"
                        WHERE "epcis"."siren" = '#{commune.siren_epci}'
                  )
                  OR  "collectivities"."territory_type" = 'Departement'
                  AND "collectivities"."territory_id" IN (
                        SELECT "departements"."id"
                        FROM "departements"
                        WHERE "departements"."code_departement" = '#{commune.code_departement}'
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
      subject(:reset_all_counters) { described_class.reset_all_counters }

      let!(:communes) { create_list(:commune, 2, :with_epci) }

      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_communes_counters()") }

      it "returns the count of collectivities" do
        expect(reset_all_counters).to eq(2)
      end

      describe "on collectivities_count" do
        before do
          create(:collectivity, territory: communes[0])
          create(:collectivity, territory: communes[1])
          create(:collectivity, territory: communes[1].epci)
          create(:collectivity, territory: communes[1].departement)
          create(:collectivity, territory: communes[1].region)

          create(:collectivity, :discarded, territory: communes[0])
          create(:collectivity, :discarded, territory: communes[1].departement)

          Commune.update_all(collectivities_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { communes[0].reload.collectivities_count }.from(0).to(1)
            .and change { communes[1].reload.collectivities_count }.from(0).to(4)
        end
      end

      describe "on offices_count" do
        before do
          offices = create_list(:office, 6)

          communes[0].offices = offices.shuffle.take(4)
          communes[1].offices = offices.shuffle.take(2)

          Commune.update_all(offices_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { communes[0].reload.offices_count }.from(0).to(4)
            .and change { communes[1].reload.offices_count }.from(0).to(2)
        end
      end

      describe "on arrondissements count" do
        before do
          communes[0].update(code_insee_parent: communes[1].code_insee)

          Commune.update_all(arrondissements_count: 99)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { communes[0].reload.arrondissements_count }.from(99).to(0)
            .and change { communes[1].reload.arrondissements_count }.from(99).to(1)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of code_insee" do
      existing_commune = create(:commune)
      another_commune  = build(:commune, code_insee: existing_commune.code_insee)

      expect { another_commune.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "cannot destroy a departement referenced from communes" do
      departement = create(:departement)
      create(:commune, departement: departement)

      expect { departement.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end

    it "cannot destroy an EPCI referenced from communes" do
      epci = create(:epci)
      create(:commune, epci: epci)

      expect { epci.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end
  end

  describe "database triggers" do
    let!(:communes) { create_list(:commune, 2) }

    describe "about counter caches" do
      describe "#collectivities_count" do
        context "with communes" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { communes }
            let(:territories) { communes }
          end
        end

        context "with EPCIs" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { create_list(:commune, 2, :with_epci) }
            let(:territories) { subjects.map(&:epci) }
          end
        end

        context "with departements" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { communes }
            let(:territories) { communes.map(&:departement) }
          end
        end

        context "with regions" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { communes }
            let(:territories) { communes.map(&:region) }
          end
        end
      end

      describe "#offices_count" do
        let(:office) { create(:office) }

        it "changes when commune is assigned to the office" do
          expect { office.communes << communes[0] }
            .to change { communes[0].reload.offices_count }.from(0).to(1)
            .and not_change { communes[1].reload.offices_count }.from(0)
        end

        it "changes when an existing code_insee is assigned to the office" do
          expect { office.office_communes.create(code_insee: communes[0].code_insee) }
            .to change { communes[0].reload.offices_count }.from(0).to(1)
            .and not_change { communes[1].reload.offices_count }.from(0)
        end

        it "doesn't change when an unknown code_insee is assigned to the office" do
          expect { office.office_communes.create(code_insee: generate(:code_insee)) }
            .to  not_change { communes[0].reload.offices_count }.from(0)
            .and not_change { communes[1].reload.offices_count }.from(0)
        end

        it "changes when commune is removed from the office" do
          office.communes << communes[0]

          expect { office.communes.delete(communes[0]) }
            .to change { communes[0].reload.offices_count }.from(1).to(0)
            .and not_change { communes[1].reload.offices_count }.from(0)
        end

        it "changes when commune updates its code_insee" do
          office.communes << communes[0]

          expect { communes[0].update(code_insee: "64024") }
            .to change { communes[0].reload.offices_count }.from(1).to(0)
            .and not_change { communes[1].reload.offices_count }.from(0)
        end

        it "doesn't changes when another commune is assigned to the office" do
          office.communes << communes[0]

          expect { office.communes << communes[1] }
            .to  not_change { communes[0].reload.offices_count }.from(1)
            .and change { communes[1].reload.offices_count }.from(0).to(1)
        end
      end

      describe "#arrondissements_count" do
        let(:arrondissement) { create(:commune) }

        it "changes when an arrondissement is created" do
          expect {
            create(:commune, commune: communes[0])
          }
            .to change { communes[0].reload.arrondissements_count }.from(0).to(1)
            .and not_change { communes[1].reload.arrondissements_count }.from(0)
        end

        it "changes when a commune is updated to become an arrondissement" do
          expect {
            arrondissement = create(:commune)
            arrondissement.update(commune: communes[0])
          }
            .to change { communes[0].reload.arrondissements_count }.from(0).to(1)
            .and not_change { communes[1].reload.arrondissements_count }.from(0)
        end

        it "changes when an arrondissement is destroyed" do
          arrondissement = create(:commune, commune: communes[0])

          expect {
            arrondissement.destroy
          }
            .to change { communes[0].reload.arrondissements_count }.from(1).to(0)
            .and not_change { communes[1].reload.arrondissements_count }.from(0)
        end

        it "changes when parent commune is created after arrondissements" do
          create(:commune, code_insee_parent: "12345")

          commune = create(:commune, code_insee: "12345")
          commune.reload

          expect(commune.arrondissements_count).to eq(1)
        end
      end
    end
  end
end
