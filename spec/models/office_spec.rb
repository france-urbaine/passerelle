# frozen_string_literal: true

require "rails_helper"

RSpec.describe Office do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:ddfip).required }

    it { is_expected.to have_many(:office_communes) }
    it { is_expected.to have_many(:office_users) }

    it { is_expected.to have_many(:users).through(:office_users) }
    it { is_expected.to have_many(:communes).through(:office_communes) }

    it { is_expected.to have_one(:departement).through(:ddfip) }
    it { is_expected.to have_many(:departement_communes).through(:departement) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates that :competences must be an array" do
      aggregate_failures do
        is_expected.to     allow_value([]).for(:competences)
        is_expected.not_to allow_value(nil).for(:competences)

        # Invalid values are converted to an empty array
        # So we cannot test with string:
        #
        #   is_expected.not_to allow_value(Office::COMPETENCES.sample).for(:competences)
      end
    end

    it "validates that :competences accept only combinaison of valid values" do
      valid_values = Office::COMPETENCES

      allowed_arrays = valid_values.map { |v| [v] }
      allowed_arrays += Array.new(4) { valid_values.sample(2) }

      invalid_arrays = []
      invalid_arrays << [Faker::Lorem.word]
      invalid_arrays << [Faker::Lorem.word, valid_values.sample]

      aggregate_failures do
        is_expected.to     allow_values(*allowed_arrays).for(:competences)
        is_expected.not_to allow_values(*invalid_arrays).for(:competences)
      end
    end

    it "validates uniqueness of :name" do
      create(:office)
      is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:ddfip_id)
    end

    it "ignores discarded records when validating uniqueness of :name" do
      create(:office, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:ddfip_id)
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_office = create(:office, :discarded)
      create(:office, ddfip: discarded_office.ddfip, name: discarded_office.name)

      expect { discarded_office.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".covering" do
      let!(:reports) { create_list(:report, 2) }

      it "returns offices covering specified reports" do
        expect {
          described_class.covering(reports).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          INNER JOIN "office_communes" ON "office_communes"."office_id" = "offices"."id"
          INNER JOIN "communes" ON "communes"."code_insee" = "office_communes"."code_insee"
          WHERE "communes"."code_insee" IN ('#{reports[0].code_insee}', '#{reports[1].code_insee}')
        SQL
      end
    end

    describe ".with_competence" do
      it "returns offices with specific competence" do
        expect {
          described_class.with_competence("evaluation_local_habitation").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "offices".*
          FROM "offices"
          WHERE ('evaluation_local_habitation' = ANY ("offices"."competences"))
        SQL
      end
    end
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for offices with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          WHERE (
                LOWER(UNACCENT("offices"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "ddfips"."code_departement" = 'Hello'
          )
        SQL
      end

      it "searches for offices by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "offices".*
          FROM   "offices"
          WHERE  (LOWER(UNACCENT("offices"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for offices by matching DDFIP name" do
        expect {
          described_class.search(ddfip_name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          WHERE           (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for offices by matching departement code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          WHERE           "ddfips"."code_departement" = '64'
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for offices with text matching the name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  (LOWER(UNACCENT("offices"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts offices by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") ASC NULLS LAST,
                   "offices"."created_at" ASC
        SQL
      end

      it "sorts offices by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") DESC NULLS FIRST,
                   "offices"."created_at" DESC
        SQL
      end

      it "sorts offices by DDFIP" do
        expect {
          described_class.order_by_param("ddfip").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") ASC NULLS LAST,
                          "offices"."created_at" ASC
        SQL
      end

      it "sorts offices by DDFIP in reversed order" do
        expect {
          described_class.order_by_param("-ddfip").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") DESC NULLS FIRST,
                          "offices"."created_at" DESC
        SQL
      end

      it "sorts offices by competences" do
        expect {
          described_class.order_by_param("competences").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" ASC,
                   "offices"."created_at" ASC
        SQL
      end

      it "sorts offices by competences in reversed order" do
        expect {
          described_class.order_by_param("-competences").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" DESC,
                   "offices"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts offices by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY ts_rank_cd(to_tsvector('french', "offices"."name"), to_tsquery('french', 'Hello')) DESC,
                   "offices"."created_at" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts offices by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") ASC NULLS LAST
        SQL
      end

      it "sorts offices by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") ASC NULLS LAST
        SQL
      end

      it "sorts offices by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_ddfip" do
      it "sorts offices by DDFIP's name without argument" do
        expect {
          described_class.order_by_ddfip.load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") ASC NULLS LAST
        SQL
      end

      it "sorts offices by DDFIP's name in ascending order" do
        expect {
          described_class.order_by_ddfip(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") ASC NULLS LAST
        SQL
      end

      it "sorts offices by DDFIP's name in descending order" do
        expect {
          described_class.order_by_ddfip(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_competences" do
      it "sorts offices by competences without argument" do
        expect {
          described_class.order_by_competences.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" ASC
        SQL
      end

      it "sorts offices by competences in ascending order" do
        expect {
          described_class.order_by_competences(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" ASC
        SQL
      end

      it "sorts offices by competences in descending order" do
        expect {
          described_class.order_by_competences(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" DESC
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { office.on_territory_collectivities }

      let(:office) { create(:office) }

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
                    SELECT     "communes"."id"
                    FROM       "communes"
                    INNER JOIN "office_communes" ON "communes"."code_insee" = "office_communes"."code_insee"
                    WHERE      "office_communes"."office_id" = '#{office.id}'
              )
              OR  "collectivities"."territory_type" = 'EPCI'
              AND "collectivities"."territory_id" IN (
                    SELECT     "epcis"."id"
                    FROM       "epcis"
                    INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                    INNER JOIN "office_communes" ON "communes"."code_insee" = "office_communes"."code_insee"
                    WHERE      "office_communes"."office_id" = '#{office.id}'
              )
              OR  "collectivities"."territory_type" = 'Departement'
              AND "collectivities"."territory_id" IN (
                    SELECT     "departements"."id"
                    FROM       "departements"
                    INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement"
                    INNER JOIN "office_communes" ON "communes"."code_insee" = "office_communes"."code_insee"
                    WHERE      "office_communes"."office_id" = '#{office.id}'
              )
            )
        SQL
      end
    end

    describe "#assignable_communes" do
      subject(:assignable_communes) { office.assignable_communes }

      let(:office) { build_stubbed(:office) }

      it { expect(assignable_communes).to be_an(ActiveRecord::Relation) }
      it { expect(assignable_communes.model).to eq(Commune) }

      it "loads the assignable communes from the departement" do
        expect {
          assignable_communes.load
        }.to perform_sql_query(<<~SQL)
          SELECT "communes".*
          FROM   "communes"
          WHERE  (
            "communes"."id" IN (
              SELECT     "communes"."id"
              FROM       "communes"
              INNER JOIN "departements" ON "communes"."code_departement" = "departements"."code_departement"
              INNER JOIN "ddfips"       ON "departements"."code_departement" = "ddfips"."code_departement"
              WHERE      "ddfips"."id" = '#{office.ddfip_id}'
                AND      "communes"."arrondissements_count" = 0
            )
            OR "communes"."code_insee_parent" IN (
              SELECT     "communes"."code_insee"
              FROM       "communes"
              INNER JOIN "departements" ON "communes"."code_departement" = "departements"."code_departement"
              INNER JOIN "ddfips"       ON "departements"."code_departement" = "ddfips"."code_departement"
              WHERE      "ddfips"."id" = '#{office.ddfip_id}'
            )
          )
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe "#competences=" do
      it "assigns the arrray passed as argument" do
        expect(
          Office.new(competences: %w[evaluation_local_habitation])
        ).to have_attributes(competences: %w[evaluation_local_habitation])
      end

      it "removes blank values from array" do
        expect(
          Office.new(competences: ["", "evaluation_local_habitation"])
        ).to have_attributes(competences: %w[evaluation_local_habitation])
      end

      it "maintains default Rails behavior when assigning non-array values" do
        expect(
          Office.new(competences: "evaluation_local_habitation")
        ).to have_attributes(competences: [])
      end
    end

    describe ".reset_all_counters" do
      let_it_be(:ddfip)   { create(:ddfip) }
      let_it_be(:offices) { create_list(:office, 2, ddfip:) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_offices_counters()")
      end

      it "returns the number of concerned collectivities" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      describe "users counts" do
        before_all do
          users = create_list(:user, 6, organization: ddfip)
          offices[0].users = users.shuffle.take(4)
          offices[1].users = users.shuffle.take(2)

          Office.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.users_count }.to(4)
            .and change { offices[1].reload.users_count }.to(2)
        end
      end

      describe "communes count" do
        before do
          communes = create_list(:commune, 6, departement: ddfip.departement)
          offices[0].communes = communes.shuffle.take(2)
          offices[1].communes = communes.shuffle.take(4)

          Office.update_all(communes_count: 99)
        end

        it "updates #communes_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.communes_count }.to(2)
            .and change { offices[1].reload.communes_count }.to(4)
        end
      end

      describe "reports counts" do
        before_all do
          create(:collectivity).tap do |collectivity|
            offices[0].tap do |office|
              create(:report, :made_for_office, collectivity:, ddfip:, office:)
              create(:report, :made_for_office, :ready, collectivity:, ddfip:, office:)
              create(:report, :made_for_office, :transmitted_to_sandbox, collectivity:, ddfip:, office:)
              create(:report, :made_for_office, :transmitted, collectivity:, ddfip:, office:)
              create(:report, :assigned_to_office, collectivity:, ddfip:, office:)
              create(:report, :assigned_to_office, :applicable, collectivity:, ddfip:, office:)
              create(:report, :assigned_to_office, :approved, collectivity:, ddfip:, office:)
              create(:report, :assigned_to_office, :canceled, collectivity:, ddfip:, office:)
              create(:report, :made_for_office, :rejected, collectivity:, ddfip:, office:)
            end

            offices[1].tap do |office|
              create(:report, :assigned_to_office, :canceled, collectivity:, ddfip:, office:)
            end
          end

          Office.update_all(
            reports_assigned_count: 99,
            reports_resolved_count: 99,
            reports_approved_count: 99,
            reports_canceled_count: 99
          )
        end

        it "updates #reports_assigned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_assigned_count }.to(4)
        end

        it "updates #reports_resolved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_resolved_count }.to(3)
            .and change { offices[1].reload.reports_resolved_count }.to(1)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_approved_count }.to(1)
            .and change { offices[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_canceled_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_canceled_count }.to(1)
            .and change { offices[1].reload.reports_canceled_count }.to(1)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of name" do
      existing_office = create(:office)
      another_office  = build(:office, ddfip_id: existing_office.ddfip_id, name: existing_office.name)

      expect { another_office.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "asserts a competence is allowed by not triggering DB constraints" do
      office = build(:office, competences: %w[evaluation_local_habitation])

      expect { office.save(validate: false) }
        .not_to raise_error
    end

    it "asserts a competence is not allowed by triggering DB constraints" do
      office = build(:office, competences: %w[foo])

      expect { office.save(validate: false) }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end
  end

  describe "database triggers" do
    let!(:ddfip)  { create(:ddfip) }
    let!(:office) { create(:office, ddfip:) }

    def create_user(*traits, **attributes)
      create(:user, *traits, organization: ddfip, **attributes)
    end

    describe "#users_count" do
      it "doesn't change on creation" do
        expect { create_user }
          .not_to change { office.reload.users_count }.from(0)
      end

      it "changes on creation when user is also assigned" do
        expect { create_user(offices: [office]) }
          .to change { office.reload.users_count }.from(0).to(1)
      end

      it "changes when user is assigned to the office" do
        user = create_user

        expect { user.offices << office }
          .to change { office.reload.users_count }.from(0).to(1)
      end

      it "changes when assigned user is removed from the office" do
        user = create_user(offices: [office])

        expect { user.offices.delete(office) }
          .to change { office.reload.users_count }.from(1).to(0)
      end

      it "changes when assigned user switches to another office" do
        user = create_user(offices: [office])
        another_office = create(:office, ddfip:)

        expect { user.offices = [another_office] }
          .to change { office.reload.users_count }.from(1).to(0)
      end

      it "changes when assigned user is discarded" do
        user = create_user(offices: [office])

        expect { user.update_columns(discarded_at: Time.current) }
          .to change { office.reload.users_count }.from(1).to(0)
      end

      it "changes when assigned user is undiscarded" do
        user = create_user(:discarded, offices: [office])

        expect { user.update_columns(discarded_at: nil) }
          .to change { office.reload.users_count }.from(0).to(1)
      end

      it "changes when assigned user is deleted" do
        user = create_user(offices: [office])

        expect { user.delete }
          .to change { office.reload.users_count }.from(1).to(0)
      end
    end

    describe "#communes_count" do
      let!(:commune) { create(:commune, code_insee: "64102") }

      it "changes when communes is assigned to the office" do
        expect { office.communes << commune }
          .to change { office.reload.communes_count }.from(0).to(1)
      end

      it "changes when an existing code_insee is assigned to the office" do
        expect { office.office_communes.create(code_insee: "64102") }
          .to change { office.reload.communes_count }.from(0).to(1)
      end

      it "doesn't change when an unknown code_insee is assigned to the office" do
        expect { office.office_communes.create(code_insee: "64024") }
          .to  not_change { office.reload.communes_count }.from(0)
      end

      it "changes when commune is removed from the office" do
        office.communes << commune

        expect { office.communes.delete(commune) }
          .to change { office.reload.communes_count }.from(1).to(0)
      end

      it "changes when commune is destroyed" do
        office.communes << commune

        expect { commune.destroy }
          .to change { office.reload.communes_count }.from(1).to(0)
      end

      it "changes when commune updates its code_insee" do
        office.communes << commune

        expect { commune.update(code_insee: "64024") }
          .to change { office.reload.communes_count }.from(1).to(0)
      end
    end

    def create_report(*traits, **attributes)
      create(:report, *traits, ddfip:, office:, **attributes)
    end

    describe "#reports_assigned_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { office.reload.reports_assigned_count }.from(0)
      end

      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { office.reload.reports_assigned_count }.from(0)
      end

      it "changes when report is assigned to the office" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .to change { office.reload.reports_assigned_count }.from(0).to(1)
      end

      it "changes when report is assigned to another office" do
        report = create_report(:transmitted)
        another_office = create(:office, ddfip:)

        expect { report.update_columns(state: "assigned", office_id: another_office.id) }
          .not_to change { office.reload.reports_assigned_count }.from(0)
      end

      it "changes when assigned report is assigned to another office" do
        report = create_report(:assigned)
        another_office = create(:office, ddfip:)

        expect { report.update_columns(office_id: another_office.id) }
          .to change { office.reload.reports_assigned_count }.from(1).to(0)
      end

      it "doesn't change when assigned report is resolved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "applicable") }
          .not_to change { office.reload.reports_assigned_count }.from(1)
      end

      it "doesn't change when resolved report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { office.reload.reports_assigned_count }.from(1)
      end

      it "changes when assigned report is discarded" do
        report = create_report(:assigned)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { office.reload.reports_assigned_count }.from(1).to(0)
      end

      it "changes when assigned report is undiscarded" do
        report = create_report(:assigned, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { office.reload.reports_assigned_count }.from(0).to(1)
      end

      it "changes when assigned report is deleted" do
        report = create_report(:assigned)

        expect { report.delete }
          .to change { office.reload.reports_assigned_count }.from(1).to(0)
      end
    end

    describe "#reports_resolved_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { office.reload.reports_resolved_count }.from(0)
      end

      it "doesn't change when report is assigned to the office" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { office.reload.reports_resolved_count }.from(0)
      end

      it "changes when assigned report is resolved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "applicable") }
          .to change { office.reload.reports_resolved_count }.to(1)
      end

      it "doesn't change when resolved report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { office.reload.reports_resolved_count }.from(1)
      end

      it "changes when resolved report is discarded" do
        report = create_report(:applicable)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { office.reload.reports_resolved_count }.from(1).to(0)
      end

      it "changes when resolved report is undiscarded" do
        report = create_report(:applicable, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { office.reload.reports_resolved_count }.from(0).to(1)
      end

      it "changes when resolved report is deleted" do
        report = create_report(:applicable)

        expect { report.delete }
          .to change { office.reload.reports_resolved_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change when report is assigned" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { office.reload.reports_approved_count }.from(0)
      end

      it "doesn't change when assigned report is resolved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "applicable") }
          .not_to change { office.reload.reports_approved_count }.from(0)
      end

      it "changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { office.reload.reports_approved_count }.to(1)
      end

      it "doesn't change when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .not_to change { office.reload.reports_approved_count }.from(0)
      end

      it "changes when approved report is discarded" do
        report = create_report(:approved)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { office.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report = create_report(:approved, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { office.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is deleted" do
        report = create_report(:approved)

        expect { report.delete }
          .to change { office.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_canceled_count" do
      it "doesn't change when report is assigned" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { office.reload.reports_canceled_count }.from(0)
      end

      it "doesn't change when assigned report is resolved" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "applicable") }
          .not_to change { office.reload.reports_canceled_count }.from(0)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { office.reload.reports_canceled_count }.to(1)
      end

      it "doesn't change when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { office.reload.reports_canceled_count }.from(0)
      end

      it "changes when canceled report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { office.reload.reports_canceled_count }.from(1).to(0)
      end

      it "changes when canceled report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { office.reload.reports_canceled_count }.from(0).to(1)
      end

      it "changes when canceled report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { office.reload.reports_canceled_count }.from(1).to(0)
      end
    end
  end
end
