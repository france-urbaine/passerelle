# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe DDFIP do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:departement).required }
    it { is_expected.to have_many(:epcis) }
    it { is_expected.to have_many(:communes) }
    it { is_expected.to have_one(:region).through(:departement) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:offices) }
    it { is_expected.to have_many(:workshops) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code_departement) }

    it { is_expected.to     allow_value("01").for(:code_departement) }
    it { is_expected.to     allow_value("2A").for(:code_departement) }
    it { is_expected.to     allow_value("987").for(:code_departement) }
    it { is_expected.not_to allow_value("1").for(:code_departement) }
    it { is_expected.not_to allow_value("123").for(:code_departement) }
    it { is_expected.not_to allow_value("3C").for(:code_departement) }

    it "validates uniqueness of :name" do
      create(:ddfip)
      is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "ignores discarded records when validating uniqueness of :name" do
      create(:ddfip, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_ddfip = create(:ddfip, :discarded)
      create(:ddfip, name: discarded_ddfip.name)

      expect { discarded_ddfip.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for DDFIPs with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE (
                LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "ddfips"."code_departement" = 'Hello'
            OR  LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  LOWER(UNACCENT("regions"."name"))      LIKE LOWER(UNACCENT('%Hello%'))
          )
        SQL
      end

      it "searches for DDFIPs by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE  (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for DDFIPs by matching departement code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE  "ddfips"."code_departement" = '64'
        SQL
      end

      it "searches for DDFIPs by matching departement name" do
        expect {
          described_class.search(departement_name: "Pyrén").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          WHERE            (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Pyrén%')))
        SQL
      end

      it "searches for DDFIPs by matching region name" do
        expect {
          described_class.search(region_name: "Sud").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Sud%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for DDFIPs with text matching the name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE (
                LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "ddfips"."code_departement" = 'Hello'
          )
        SQL
      end
    end

    describe ".order_by_param" do
      it "orders DDFIPs by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") ASC,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by name in descendant order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") DESC,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "orders DDFIPs by departement" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" ASC,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by departement in descendant order" do
        expect {
          described_class.order_by_param("-departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" DESC,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "orders DDFIPs by region" do
        expect {
          described_class.order_by_param("region").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" ASC,
                          "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by region in descendant order" do
        expect {
          described_class.order_by_param("-region").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" DESC,
                          "ddfips"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders DDFIPs by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY ts_rank_cd(to_tsvector('french', "ddfips"."name"), to_tsquery('french', 'Hello')) DESC,
                   "ddfips"."created_at" ASC
        SQL
      end
    end

    describe ".covering" do
      let!(:reports) { create_list(:report, 3) }

      it "returns ddfips covering specified reports" do
        expect {
          described_class.covering(reports)
        }.to perform_sql_query(<<~SQL.squish)
          SELECT DISTINCT "ddfips".*
          FROM "ddfips"
          INNER JOIN "communes" ON "communes"."code_departement" = "ddfips"."code_departement"
          INNER JOIN "reports" ON "reports"."code_insee" = "communes"."code_insee"
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { ddfip.on_territory_collectivities }

      let(:ddfip) { create(:ddfip) }

      it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
      it { expect(on_territory_collectivities.model).to eq(Collectivity) }

      it "loads the registered collectivities in the DDFIP departement" do
        expect { on_territory_collectivities.load }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND (
                  "collectivities"."territory_type" = 'Commune'
              AND "collectivities"."territory_id" IN (
                    SELECT "communes"."id"
                    FROM   "communes"
                    WHERE  "communes"."code_departement" = '#{ddfip.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'EPCI'
              AND "collectivities"."territory_id" IN (
                    SELECT     "epcis"."id"
                    FROM       "epcis"
                    INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                    WHERE      "communes"."code_departement" = '#{ddfip.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'Departement'
              AND "collectivities"."territory_id" IN (
                    SELECT "departements"."id"
                    FROM   "departements"
                    WHERE  "departements"."code_departement" = '#{ddfip.code_departement}'
              )
            )
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:ddfips) { create_list(:ddfip, 2) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_ddfips_counters()")
      end

      it "returns the number of concerned collectivities" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: ddfips[0])
          create_list(:user, 2, organization: ddfips[1])
          create(:user, :discarded, organization: ddfips[0])

          DDFIP.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.users_count }.to(4)
            .and change { ddfips[1].reload.users_count }.to(2)
        end
      end

      describe "collectivities counts" do
        before_all do
          create(:collectivity, :commune)

          ddfips[0].tap do |ddfip|
            epcis     = create_list(:epci, 3)
            communes  = create_list(:commune, 3, epci: epcis[0], departement: ddfip.departement)
            communes += create_list(:commune, 2, epci: epcis[1], departement: ddfip.departement)

            create(:collectivity, territory: epcis[0])
            create(:collectivity, territory: epcis[1])
            create(:collectivity, territory: communes[0])
            create(:collectivity, territory: communes[1])
            create(:collectivity, territory: communes[3])
            create(:collectivity, :discarded, territory: communes[2])
            create(:collectivity, :discarded, territory: communes[4])
          end

          ddfips[1].tap do |ddfip|
            create(:collectivity, territory: ddfip.departement)
            create(:collectivity, territory: ddfip.departement.region)
          end

          DDFIP.update_all(collectivities_count: 99)
        end

        it "updates #collectivities_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.collectivities_count }.to(5)
            .and change { ddfips[1].reload.collectivities_count }.to(2)
        end
      end

      describe "offices counts" do
        before_all do
          create_list(:office, 2)
          create_list(:office, 2, ddfip: ddfips[0])
          create_list(:office, 4, ddfip: ddfips[1])
          create(:office, :discarded, ddfip: ddfips[0])

          DDFIP.update_all(offices_count: 99)
        end

        it "updates #offices_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.offices_count }.to(2)
            .and change { ddfips[1].reload.offices_count }.to(4)
        end
      end

      describe "reports counts" do
        before_all do
          ddfips[0].tap do |ddfip|
            create(:commune, departement: ddfip.departement).tap do |commune|
              create(:collectivity, territory: commune).tap do |collectivity|
                create(:report, collectivity:, ddfip:)
                create(:report, :ready, collectivity:, ddfip:)
                create_list(:report, 2, :approved, collectivity:, ddfip:)
                create_list(:report, 3, :rejected, collectivity:, ddfip:)
              end
            end
          end

          ddfips[1].tap do |ddfip|
            create(:commune, departement: ddfip.departement).tap do |commune|
              create(:collectivity, territory: commune).tap do |collectivity|
                create(:report, :denied, collectivity:, ddfip:)
              end
            end
          end

          DDFIP.update_all(
            reports_transmitted_count: 99,
            reports_denied_count:      99,
            reports_processing_count:  99,
            reports_approved_count:    99,
            reports_rejected_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_transmitted_count }.to(5)
            .and change { ddfips[1].reload.reports_transmitted_count }.to(1)
        end

        it "updates #reports_denied_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_denied_count }.to(0)
            .and change { ddfips[1].reload.reports_denied_count }.to(1)
        end

        it "updates #reports_processing_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_processing_count }.to(0)
            .and change { ddfips[1].reload.reports_processing_count }.to(0)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_approved_count }.to(2)
            .and change { ddfips[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_rejected_count }.to(3)
            .and change { ddfips[1].reload.reports_rejected_count }.to(0)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of name" do
      existing_ddfip = create(:ddfip)
      another_ddfip  = build(:ddfip, name: existing_ddfip.name)

      expect { another_ddfip.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "ignores discarded records when asserting the uniqueness of SIREN" do
      existing_ddfip = create(:ddfip, :discarded)
      another_ddfip  = build(:ddfip, name: existing_ddfip.name)

      expect { another_ddfip.save(validate: false) }
        .not_to raise_error
    end

    it "cannot destroy a departement referenced from ddfips" do
      departement = create(:departement)
      create(:ddfip, departement: departement)

      expect { departement.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end
  end

  describe "database triggers" do
    let!(:ddfip) { create(:ddfip) }

    describe "#users_count" do
      let(:user) { create(:user, organization: ddfip) }

      it "changes on creation" do
        expect { user }
          .to change { ddfip.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user

        expect { user.destroy }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user

        expect { user.discard }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user.discard

        expect { user.undiscard }
          .to change { ddfip.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user
        another_ddfip = create(:ddfip)

        expect { user.update(organization: another_ddfip) }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end
    end

    describe "#collectivities_count" do
      context "with communes" do
        let(:commune)      { create(:commune, departement: ddfip.departement) }
        let(:collectivity) { create(:collectivity, territory: commune) }

        it "changes on creation" do
          expect { collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is discarded" do
          collectivity

          expect { collectivity.discard }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity.discard

          expect { collectivity.undiscard }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is deleted" do
          collectivity

          expect { collectivity.destroy }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity switches to another territory" do
          collectivity
          another_commune = create(:commune)

          expect { collectivity.update(territory: another_commune) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with EPCIs having communes in the departements" do
        let(:commune)      { create(:commune, :with_epci, departement: ddfip.departement) }
        let(:collectivity) { create(:collectivity, territory: commune.epci) }

        it "changes on creation" do
          expect { collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is discarded" do
          collectivity

          expect { collectivity.discard }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity.discard

          expect { collectivity.undiscard }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is deleted" do
          collectivity

          expect { collectivity.destroy }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity switches to another territory" do
          collectivity
          another_epci = create(:epci)

          expect { collectivity.update(territory: another_epci) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with an EPCI belonging to the departement but without communes in it" do
        let(:epci)         { create(:epci, departement: ddfip.departement) }
        let(:collectivity) { create(:collectivity, territory: epci) }

        it "doesn't changes on creation" do
          expect { collectivity }
            .not_to change { ddfip.reload.collectivities_count }.from(0)
        end
      end

      context "with departements" do
        let(:collectivity) { create(:collectivity, territory: ddfip.departement) }

        it "changes on creation" do
          expect { collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is discarded" do
          collectivity

          expect { collectivity.discard }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity.discard

          expect { collectivity.undiscard }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is deleted" do
          collectivity

          expect { collectivity.destroy }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity switches to another territory" do
          collectivity
          another_departement = create(:departement)

          expect { collectivity.update(territory: another_departement) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with regions" do
        let(:collectivity) { create(:collectivity, territory: ddfip.departement.region) }

        it "changes on creation" do
          expect { collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is discarded" do
          collectivity

          expect { collectivity.discard }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity.discard

          expect { collectivity.undiscard }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity is deleted" do
          collectivity

          expect { collectivity.destroy }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity switches to another territory" do
          collectivity
          another_region = create(:region)

          expect { collectivity.update(territory: another_region) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end
    end

    describe "#offices_count" do
      let(:office) { create(:office, ddfip:) }

      it "changes on creation" do
        expect { office }
          .to change { ddfip.reload.offices_count }.from(0).to(1)
      end

      it "changes on deletion" do
        office

        expect { office.destroy }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end

      it "changes when office is discarded" do
        office

        expect { office.discard }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end

      it "changes when office is undiscarded" do
        office.discard

        expect { office.undiscard }
          .to change { ddfip.reload.offices_count }.from(0).to(1)
      end

      it "changes when office switches to another ddfip" do
        office
        another_ddfip = create(:ddfip)

        expect { office.update(ddfip: another_ddfip) }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      let!(:ddfip) { create(:ddfip) }
      let(:commune)      { create(:commune, departement: ddfip.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }
      let(:report)       { create(:report, collectivity:, ddfip:) }

      it "doesn't change when report is created" do
        expect { report }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report

        expect { report.transmit! }
          .to change { ddfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report.update(sandbox: true)

        expect { report.transmit! }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is discarded" do
        report.transmit!

        expect { report.discard }
          .to change { ddfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when report is undiscarded" do
        report.transmit!
        report.discard

        expect { report.undiscard }
          .to change { ddfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when report is deleted" do
        report.transmit!

        expect { report.destroy }
          .to change { ddfip.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_denied_count" do
      let!(:ddfip) { create(:ddfip) }
      let(:commune)      { create(:commune, departement: ddfip.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }
      let(:report)       { create(:report, collectivity:, ddfip:) }

      it "doesn't change when reports are transmitted" do
        expect { report.transmit! }
          .not_to change { ddfip.reload.reports_denied_count }.from(0)
      end

      it "changes when report is denied" do
        report

        expect { report.deny! }
          .to change { ddfip.reload.reports_denied_count }.from(0).to(1)
      end

      it "doesn't change when report is assigned" do
        report

        expect { report.assign! }
          .not_to change { ddfip.reload.reports_denied_count }.from(0)
      end

      it "changes when denied report is then assigned" do
        report.deny!

        expect { report.assign! }
          .to change { ddfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is discarded" do
        report.deny!

        expect { report.discard }
          .to change { ddfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is undiscarded" do
        report.deny!
        report.discard

        expect { report.undiscard }
          .to change { ddfip.reload.reports_denied_count }.from(0).to(1)
      end

      it "changes when denied report is deleted" do
        report.deny!

        expect { report.delete }
          .to change { ddfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is sandboxed" do
        report.deny!

        expect { report.update(sandbox: true) }
          .to change { ddfip.reload.reports_denied_count }.from(1).to(0)
      end
    end

    describe "#reports_processing_count" do
      let!(:ddfip) { create(:ddfip) }
      let(:commune)      { create(:commune, departement: ddfip.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }
      let(:report)       { create(:report, collectivity:, ddfip:) }

      it "doesn't change when reports are transmitted" do
        expect { report }
          .not_to change { ddfip.reload.reports_processing_count }.from(0)
      end

      it "changes when report is assigned" do
        report

        expect { report.assign! }
          .to change { ddfip.reload.reports_processing_count }.from(0).to(1)
      end

      it "doesn't change when report is denied" do
        report

        expect { report.deny! }
          .not_to change { ddfip.reload.reports_processing_count }.from(0)
      end

      it "changes when assigned report is then denied" do
        report.assign!

        expect { report.deny! }
          .to change { ddfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when reports are approved" do
        report.assign!

        expect { report.approve! }
          .to change { ddfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when reports are rejected" do
        report.assign!

        expect { report.reject! }
          .to change { ddfip.reload.reports_processing_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      let!(:ddfip) { create(:ddfip) }
      let(:commune)      { create(:commune, departement: ddfip.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }
      let(:report)       { create(:report, :assigned, collectivity:, ddfip:) }

      it "doesn't change when report is assigned" do
        expect { report }
          .not_to change { ddfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { ddfip.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report

        expect { report.approve! }
          .to change { ddfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report.approve!

        expect { report.update(approved_at: nil, state: "processing") }
          .to change { ddfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report.approve!

        expect { report.reject! }
          .to change { ddfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is sandboxed" do
        report.approve!

        expect { report.update(sandbox: true) }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is discarded" do
        report.approve!

        expect { report.discard }
          .to change { collectivity.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report.approve!
        report.discard

        expect { report.undiscard }
          .to change { collectivity.reload.reports_approved_count }.from(0).to(1)
      end
    end

    describe "#reports_rejected_count" do
      let!(:ddfip) { create(:ddfip) }
      let(:commune)      { create(:commune, departement: ddfip.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }
      let(:report)       { create(:report, :assigned, collectivity:, ddfip:) }

      it "doesn't change when report is assigned" do
        expect { report }
          .not_to change { ddfip.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { ddfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report

        expect { report.reject! }
          .to change { ddfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report.reject!

        expect { report.update(rejected_at: nil, state: "processing") }
          .to change { ddfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report.reject!

        expect { report.approve! }
          .to change { ddfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is sandboxed" do
        report.reject!

        expect { report.update(sandbox: true) }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is discarded" do
        report.reject!

        expect { report.discard }
          .to change { collectivity.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report.reject!
        report.discard

        expect { report.undiscard }
          .to change { collectivity.reload.reports_rejected_count }.from(0).to(1)
      end
    end
  end
end
