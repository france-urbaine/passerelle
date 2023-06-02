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

    it { is_expected.to     allow_value("74123").for(:code_insee) }
    it { is_expected.to     allow_value("2A013").for(:code_insee) }
    it { is_expected.to     allow_value("97102").for(:code_insee) }
    it { is_expected.not_to allow_value("1A674").for(:code_insee) }
    it { is_expected.not_to allow_value("123456").for(:code_insee) }

    it { is_expected.to     allow_value("01").for(:code_departement) }
    it { is_expected.to     allow_value("2A").for(:code_departement) }
    it { is_expected.to     allow_value("987").for(:code_departement) }
    it { is_expected.not_to allow_value("1").for(:code_departement) }
    it { is_expected.not_to allow_value("123").for(:code_departement) }
    it { is_expected.not_to allow_value("3C").for(:code_departement) }

    it { is_expected.to     allow_value("801453893").for(:siren_epci) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren_epci) }
    it { is_expected.not_to allow_value("1234567891").for(:siren_epci) }
  end

  # Normalization callbacks
  # ----------------------------------------------------------------------------
  describe "attribute normalization" do
    def build_record(**attributes)
      user = build(:commune, **attributes)
      user.validate
      user
    end

    describe "#siren_epci" do
      it { expect(build_record(siren_epci: "")).to  have_attributes(siren_epci: nil) }
      it { expect(build_record(siren_epci: nil)).to have_attributes(siren_epci: nil) }
    end
  end

  # Other callbacks
  # ----------------------------------------------------------------------------
  describe "callbacks" do
    # Use only one departement to reduce the number of queries and records to create
    let_it_be(:departement) { create(:departement) }

    def create_record(**attributes)
      create(:commune, departement: departement, **attributes)
    end

    describe "#generate_qualified_name" do
      it { expect(create_record(name: "Bayonne")).to     have_attributes(qualified_name: "Commune de Bayonne") }
      it { expect(create_record(name: "Le Chateley")).to have_attributes(qualified_name: "Commune du Chateley") }
      it { expect(create_record(name: "La Rochelle")).to have_attributes(qualified_name: "Commune de la Rochelle") }
      it { expect(create_record(name: "Les Arcs")).to    have_attributes(qualified_name: "Commune des Arcs") }
      it { expect(create_record(name: "L'Hermitage")).to have_attributes(qualified_name: "Commune de L'Hermitage") }
      it { expect(create_record(name: "Labbeville")).to  have_attributes(qualified_name: "Commune de Labbeville") }
      it { expect(create_record(name: "Avensan")) .to    have_attributes(qualified_name: "Commune d'Avensan") }
    end
  end

  # Search scope
  # ----------------------------------------------------------------------------
  describe "scopes" do
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

    describe ".search" do
      it "searches for communes with text" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE (
            LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR "communes"."code_insee" = 'Hello'
            OR "communes"."siren_epci" = 'Hello'
            OR "communes"."code_departement" = 'Hello'
            OR LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          )
        SQL
      end

      it "searches for communes with text matching a single attribute" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for communes with text matching the qualified name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE (
            LOWER(UNACCENT("communes"."qualified_name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR "communes"."code_insee" = 'Hello'
          )
        SQL
      end
    end

    describe ".order_by_param" do
      it "orders communes by commune codes" do
        expect {
          described_class.order_by_param("commune").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          ORDER BY UNACCENT("communes"."name") ASC, "communes"."code_insee" ASC
        SQL
      end

      it "orders communes by departement codes" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          ORDER BY "communes"."code_departement" ASC, "communes"."code_insee" ASC
        SQL
      end

      it "orders communes by EPCI names" do
        expect {
          described_class.order_by_param("epci").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY UNACCENT("epcis"."name") ASC, "communes"."code_insee" ASC
        SQL
      end

      it "orders communes by EPCI names in descendant order" do
        expect {
          described_class.order_by_param("-epci").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
          ORDER BY UNACCENT("epcis"."name") DESC, "communes"."code_insee" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders communes by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          ORDER BY ts_rank_cd(to_tsvector('french', "communes"."name"), to_tsquery('french', 'Hello')) DESC,
                  "communes"."code_insee" ASC
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "#on_territory_collectivities" do
    context "without EPCI attached" do
      let(:commune) { create(:commune) }

      it do
        expect {
          commune.on_territory_collectivities.load
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

      it do
        expect {
          commune.on_territory_collectivities.load
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

  # Reset counters
  # ----------------------------------------------------------------------------
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
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    pending "TODO"
  end

  describe "database triggers" do
    let!(:communes) { create_list(:commune, 2) }

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
          .to      change { communes[0].reload.offices_count }.from(0).to(1)
          .and not_change { communes[1].reload.offices_count }.from(0)
      end

      it "changes when an existing code_insee is assigned to the office" do
        expect { office.office_communes.create(code_insee: communes[0].code_insee) }
          .to      change { communes[0].reload.offices_count }.from(0).to(1)
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
          .to      change { communes[0].reload.offices_count }.from(1).to(0)
          .and not_change { communes[1].reload.offices_count }.from(0)
      end

      it "changes when commune updates its code_insee" do
        office.communes << communes[0]

        expect { communes[0].update(code_insee: "64024") }
          .to      change { communes[0].reload.offices_count }.from(1).to(0)
          .and not_change { communes[1].reload.offices_count }.from(0)
      end

      it "doesn't changes when another commune is assigned to the office" do
        office.communes << communes[0]

        expect { office.communes << communes[1] }
          .to  not_change { communes[0].reload.offices_count }.from(1)
          .and     change { communes[1].reload.offices_count }.from(0).to(1)
      end
    end
  end
end
