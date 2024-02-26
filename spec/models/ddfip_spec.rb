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
    describe ".covering" do
      it "returns DDFIPs covering a reports relation" do
        reports = Report.where(reference: "2023-12-01")

        expect {
          described_class.covering(reports).load
        }.to perform_sql_query(<<~SQL)
           SELECT DISTINCT "ddfips".*
          FROM            "ddfips"
          INNER JOIN      "communes" ON "communes"."code_departement" = "ddfips"."code_departement"
          INNER JOIN      "reports" ON "reports"."code_insee" = "communes"."code_insee"
          WHERE           "reports"."reference" = '2023-12-01'
        SQL
      end

      it "returns DDFIPs covering an array of reports" do
        reports = create_list(:report, 2)

        expect {
          described_class.covering(reports).load
        }.to perform_sql_query(<<~SQL)
          SELECT DISTINCT "ddfips".*
          FROM            "ddfips"
          INNER JOIN      "communes" ON "communes"."code_departement" = "ddfips"."code_departement"
          WHERE           "communes"."code_insee" IN ('#{reports[0].code_insee}', '#{reports[1].code_insee}')
        SQL
      end
    end
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
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
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts DDFIPs by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") ASC NULLS LAST,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "sorts DDFIPs by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") DESC NULLS FIRST,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "sorts DDFIPs by departement" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" ASC,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "sorts DDFIPs by departement in reversed order" do
        expect {
          described_class.order_by_param("-departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" DESC,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "sorts DDFIPs by region" do
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

      it "sorts DDFIPs by region in reversed order" do
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
      it "sorts DDFIPs by search score" do
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

    describe ".order_by_name" do
      it "sorts DDFIPs by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") ASC NULLS LAST
        SQL
      end

      it "sorts DDFIPs by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") ASC NULLS LAST
        SQL
      end

      it "sorts DDFIPs by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_departement" do
      it "sorts DDFIPs by departement's code without argument" do
        expect {
          described_class.order_by_departement.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" ASC
        SQL
      end

      it "sorts DDFIPs by departement's code in ascending order" do
        expect {
          described_class.order_by_departement(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" ASC
        SQL
      end

      it "sorts DDFIPs by departement's code in descending order" do
        expect {
          described_class.order_by_departement(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" DESC
        SQL
      end
    end

    describe ".order_by_region" do
      it "sorts DDFIPs by region's code without argument" do
        expect {
          described_class.order_by_region.load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" ASC
        SQL
      end

      it "sorts DDFIPs by region's code in ascending order" do
        expect {
          described_class.order_by_region(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" ASC
        SQL
      end

      it "sorts DDFIPs by region's code in descending order" do
        expect {
          described_class.order_by_region(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" DESC
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
          create(:collectivity).tap do |collectivity|
            ddfips[0].tap do |ddfip|
              create(:report, collectivity:, ddfip:)
              create(:report, :ready, collectivity:, ddfip:)
              create(:report, :transmitted_to_sandbox, collectivity:, ddfip:)
              create(:report, :transmitted_to_ddfip, collectivity:, ddfip:)
              create(:report, :assigned_by_ddfip, collectivity:, ddfip:)
              create(:report, :assigned_by_ddfip, :applicable, collectivity:, ddfip:)
              create(:report, :approved_by_ddfip, collectivity:, ddfip:)
              create(:report, :canceled_by_ddfip, collectivity:, ddfip:)
              create(:report, :rejected_by_ddfip, collectivity:, ddfip:)
            end

            ddfips[1].tap do |ddfip|
              create(:report, :canceled_by_ddfip, collectivity:, ddfip:)
            end
          end

          DDFIP.update_all(
            reports_transmitted_count: 99,
            reports_unassigned_count:  99,
            reports_accepted_count:    99,
            reports_rejected_count:    99,
            reports_approved_count:    99,
            reports_canceled_count:    99,
            reports_returned_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_transmitted_count }.to(6)
            .and change { ddfips[1].reload.reports_transmitted_count }.to(1)
        end

        it "updates #reports_unassigned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_unassigned_count }.to(1)
            .and change { ddfips[1].reload.reports_unassigned_count }.to(0)
        end

        it "updates #reports_accepted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_accepted_count }.to(4)
            .and change { ddfips[1].reload.reports_accepted_count }.to(1)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_rejected_count }.to(1)
            .and change { ddfips[1].reload.reports_rejected_count }.to(0)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_approved_count }.to(1)
            .and change { ddfips[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_canceled_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_canceled_count }.to(1)
            .and change { ddfips[1].reload.reports_canceled_count }.to(1)
        end

        it "updates #reports_returned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { ddfips[0].reload.reports_returned_count }.to(3)
            .and change { ddfips[1].reload.reports_returned_count }.to(1)
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

    def create_user(*traits, **attributes)
      create(:user, *traits, organization: ddfip, **attributes)
    end

    describe "#users_count" do
      it "changes on creation" do
        expect { create_user }
          .to change { ddfip.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user = create_user

        expect { user.delete }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user = create_user

        expect { user.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user = create_user(:discarded)

        expect { user.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user = create_user
        another_ddfip = create(:ddfip)

        expect { user.update_columns(organization_id: another_ddfip.id) }
          .to change { ddfip.reload.users_count }.from(1).to(0)
      end
    end

    describe "#collectivities_count" do
      context "with communes" do
        let(:commune) { create(:commune, departement: ddfip.departement) }

        def create_collectivity(*traits, **attributes)
          create(:collectivity, *traits, territory: commune, **attributes)
        end

        it "changes on creation" do
          expect { create_collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes on deletion" do
          collectivity = create_collectivity

          expect { collectivity.delete }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is discarded" do
          collectivity = create_collectivity

          expect { collectivity.update_columns(discarded_at: Time.current) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity = create_collectivity(:discarded)

          expect { collectivity.update_columns(discarded_at: nil) }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity switches to another territory" do
          collectivity = create_collectivity
          another_territory = create(:commune)

          expect { collectivity.update_columns(territory_id: another_territory.id) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with EPCIs having communes in the departements" do
        let(:commune) { create(:commune, :with_epci, departement: ddfip.departement) }

        def create_collectivity(*traits, **attributes)
          create(:collectivity, *traits, territory: commune.epci, **attributes)
        end

        it "changes on creation" do
          expect { create_collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes on deletion" do
          collectivity = create_collectivity

          expect { collectivity.delete }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is discarded" do
          collectivity = create_collectivity

          expect { collectivity.update_columns(discarded_at: Time.current) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity = create_collectivity(:discarded)

          expect { collectivity.update_columns(discarded_at: nil) }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity switches to another territory" do
          collectivity = create_collectivity
          another_territory = create(:epci)

          expect { collectivity.update_columns(territory_id: another_territory.id) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with an EPCI belonging to the departement but without communes in it" do
        let(:epci) { create(:epci, departement: ddfip.departement) }

        def create_collectivity(*traits, **attributes)
          create(:collectivity, *traits, territory: epci, **attributes)
        end

        it "doesn't changes on creation" do
          expect { create_collectivity }
            .not_to change { ddfip.reload.collectivities_count }.from(0)
        end
      end

      context "with departements" do
        def create_collectivity(*traits, **attributes)
          create(:collectivity, *traits, territory: ddfip.departement, **attributes)
        end

        it "changes on creation" do
          expect { create_collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes on deletion" do
          collectivity = create_collectivity

          expect { collectivity.delete }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is discarded" do
          collectivity = create_collectivity

          expect { collectivity.update_columns(discarded_at: Time.current) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity = create_collectivity(:discarded)

          expect { collectivity.update_columns(discarded_at: nil) }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity switches to another territory" do
          collectivity = create_collectivity
          another_territory = create(:departement)

          expect { collectivity.update_columns(territory_id: another_territory.id) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end

      context "with regions" do
        def create_collectivity(*traits, **attributes)
          create(:collectivity, *traits, territory: ddfip.departement.region, **attributes)
        end

        it "changes on creation" do
          expect { create_collectivity }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes on deletion" do
          collectivity = create_collectivity

          expect { collectivity.delete }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is discarded" do
          collectivity = create_collectivity

          expect { collectivity.update_columns(discarded_at: Time.current) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end

        it "changes when collectivity is undiscarded" do
          collectivity = create_collectivity(:discarded)

          expect { collectivity.update_columns(discarded_at: nil) }
            .to change { ddfip.reload.collectivities_count }.from(0).to(1)
        end

        it "changes when collectivity switches to another territory" do
          collectivity = create_collectivity
          another_territory = create(:region)

          expect { collectivity.update_columns(territory_id: another_territory.id) }
            .to change { ddfip.reload.collectivities_count }.from(1).to(0)
        end
      end
    end

    def create_office(*traits, **attributes)
      create(:office, *traits, ddfip:, **attributes)
    end

    describe "#offices_count" do
      it "changes on creation" do
        expect { create_office }
          .to change { ddfip.reload.offices_count }.from(0).to(1)
      end

      it "changes on deletion" do
        office = create_office

        expect { office.delete }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end

      it "changes when office is discarded" do
        office = create_office

        expect { office.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end

      it "changes when office is undiscarded" do
        office = create_office(:discarded)

        expect { office.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.offices_count }.from(0).to(1)
      end

      it "changes when office switches to another ddfip" do
        office = create_office
        another_ddfip = create(:ddfip)

        expect { office.update_columns(ddfip_id: another_ddfip.id) }
          .to change { ddfip.reload.offices_count }.from(1).to(0)
      end
    end

    def create_report(*traits, **attributes)
      create(:report, *traits, ddfip:, **attributes)
    end

    describe "#reports_transmitted_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .to change { ddfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report = create_report

        expect { report.update_columns(state: "transmitted", sandbox: true) }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(0)
      end

      it "doesn't change when report is transmitted to another DDFIP" do
        report = create_report
        another_ddfip = create(:ddfip)

        expect { report.update_columns(state: "transmitted", ddfip_id: another_ddfip.id) }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(0)
      end

      it "doesn't change when transmitted report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { ddfip.reload.reports_transmitted_count }.from(1)
      end

      it "changes when transmitted report is discarded" do
        report = create_report(:transmitted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report = create_report(:transmitted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report = create_report(:transmitted)

        expect { report.delete }
          .to change { ddfip.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_unassigned_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { ddfip.reload.reports_unassigned_count }.from(0)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .to change { ddfip.reload.reports_unassigned_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report = create_report

        expect { report.update_columns(state: "transmitted", sandbox: true) }
          .not_to change { ddfip.reload.reports_unassigned_count }.from(0)
      end

      it "doesn't change when report is transmitted to another DDFIP" do
        report = create_report
        another_ddfip = create(:ddfip)

        expect { report.update_columns(state: "transmitted", ddfip_id: another_ddfip.id) }
          .not_to change { ddfip.reload.reports_unassigned_count }.from(0)
      end

      it "doesn't change when transmitted report is acknowledged" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "acknowledged") }
          .not_to change { ddfip.reload.reports_unassigned_count }.from(1)
      end

      it "doesn't change when transmitted report is accepted" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "accepted") }
          .not_to change { ddfip.reload.reports_unassigned_count }.from(1)
      end

      it "change when accepted report is assigned" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "assigned") }
          .to change { ddfip.reload.reports_unassigned_count }.from(1).to(0)
      end

      it "changes when transmitted report is discarded" do
        report = create_report(:transmitted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_unassigned_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report = create_report(:transmitted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_unassigned_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report = create_report(:transmitted)

        expect { report.delete }
          .to change { ddfip.reload.reports_unassigned_count }.from(1).to(0)
      end
    end

    describe "#reports_accepted_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { ddfip.reload.reports_accepted_count }.from(0)
      end

      it "changes when report is accepted" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "accepted") }
          .to change { ddfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .to change { ddfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is rejected" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "rejected") }
          .not_to change { ddfip.reload.reports_accepted_count }.from(0)
      end

      it "changes when accepted report is then rejected" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "rejected") }
          .to change { ddfip.reload.reports_accepted_count }.from(1).to(0)
      end

      it "doesn't change when accepted report is assigned" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { ddfip.reload.reports_accepted_count }.from(1)
      end

      it "doesn't change when resolved report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { ddfip.reload.reports_accepted_count }.from(1)
      end

      it "changes when accepted report is discarded" do
        report = create_report(:accepted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_accepted_count }.from(1).to(0)
      end

      it "changes when accepted report is undiscarded" do
        report = create_report(:accepted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when accepted report is deleted" do
        report = create_report(:accepted)

        expect { report.delete }
          .to change { ddfip.reload.reports_accepted_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { ddfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report

        expect { report.update_columns(state: "rejected") }
          .to change { ddfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "doesn't change when report is accepted" do
        report = create_report

        expect { report.update_columns(state: "accepted") }
          .not_to change { ddfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected report is then accepted" do
        report = create_report(:rejected)

        expect { report.update_columns(state: "assigned") }
          .to change { ddfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is discarded" do
        report = create_report(:rejected)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report = create_report(:rejected, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is deleted" do
        report = create_report(:rejected)

        expect { report.delete }
          .to change { ddfip.reload.reports_rejected_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { ddfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { ddfip.reload.reports_approved_count }.from(0)
      end

      it "changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { ddfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "doesn't changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .not_to change { ddfip.reload.reports_approved_count }.from(0)
      end

      it "changes when approved report is discarded" do
        report = create_report(:approved)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report = create_report(:approved, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is deleted" do
        report = create_report(:approved)

        expect { report.delete }
          .to change { ddfip.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_canceled_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { ddfip.reload.reports_canceled_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { ddfip.reload.reports_canceled_count }.from(0)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { ddfip.reload.reports_canceled_count }.from(0).to(1)
      end

      it "doesn't changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { ddfip.reload.reports_canceled_count }.from(0)
      end

      it "changes when canceled report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_canceled_count }.from(1).to(0)
      end

      it "changes when canceled report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_canceled_count }.from(0).to(1)
      end

      it "changes when canceled report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { ddfip.reload.reports_canceled_count }.from(1).to(0)
      end
    end

    describe "#reports_returned_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { ddfip.reload.reports_returned_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .to change { ddfip.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { ddfip.reload.reports_returned_count }.from(0).to(1)
      end

      it "doesn't changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { ddfip.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when returned report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { ddfip.reload.reports_returned_count }.from(1).to(0)
      end

      it "changes when returned report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { ddfip.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when returned report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { ddfip.reload.reports_returned_count }.from(1).to(0)
      end
    end
  end
end
