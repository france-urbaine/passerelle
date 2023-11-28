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

    describe ".order_by_param" do
      it "orders offices by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") ASC,
                   "offices"."created_at" ASC
        SQL
      end

      it "orders offices by name in descendant order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY UNACCENT("offices"."name") DESC,
                   "offices"."created_at" DESC
        SQL
      end

      it "orders offices by DDFIP" do
        expect {
          described_class.order_by_param("ddfip").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") ASC,
                          "offices"."created_at" ASC
        SQL
      end

      it "orders offices by DDFIP in descendant order" do
        expect {
          described_class.order_by_param("-ddfip").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "offices".*
          FROM            "offices"
          LEFT OUTER JOIN "ddfips" ON "ddfips"."id" = "offices"."ddfip_id"
          ORDER BY        UNACCENT("ddfips"."name") DESC,
                          "offices"."created_at" DESC
        SQL
      end

      it "orders offices by competences" do
        expect {
          described_class.order_by_param("competences").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "offices".*
          FROM     "offices"
          ORDER BY "offices"."competences" ASC,
                   "offices"."created_at" ASC
        SQL
      end

      it "orders offices by competences in descendant order" do
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
      it "orders offices by search score" do
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
            OR "communes"."code_arrondissement" IN (
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

      describe "reports & packages counts" do
        before_all do
          create(:commune, departement: ddfip.departement).tap do |commune|
            offices[0].communes << commune
            form_type = offices[0].competences.sample

            create(:collectivity, territory: commune).tap do |collectivity|
              create(:package, :with_reports, collectivity:, form_type:)
              create(:package, :with_reports, :sandbox, collectivity:, form_type:)
              create(:package, :with_reports, :assigned, collectivity:, form_type:) do |package|
                create_list(:report, 2, :approved, collectivity:, package:, form_type:)
                create_list(:report, 3, :rejected, collectivity:, package:, form_type:)
              end
            end
          end

          create(:commune, departement: ddfip.departement).tap do |commune|
            offices[1].communes << commune
            form_type = offices[1].competences.sample

            create(:collectivity, territory: commune).tap do |collectivity|
              create(:package, :with_reports, :returned, collectivity:, form_type:)
              create(:package, :assigned, collectivity:, form_type:) do |package|
                create(:report, :debated, collectivity:, package:, form_type:)
              end
            end
          end

          Office.update_all(
            reports_assigned_count: 99,
            reports_pending_count:  99,
            reports_debated_count:  99,
            reports_approved_count: 99,
            reports_rejected_count: 99
          )
        end

        it "updates #reports_assigned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_assigned_count }.to(6)
            .and change { offices[1].reload.reports_assigned_count }.to(1)
        end

        it "updates #reports_pending_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_pending_count }.to(1)
            .and change { offices[1].reload.reports_pending_count }.to(0)
        end

        it "updates #reports_debated_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_debated_count }.to(0)
            .and change { offices[1].reload.reports_debated_count }.to(1)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_approved_count }.to(2)
            .and change { offices[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { offices[0].reload.reports_rejected_count }.to(3)
            .and change { offices[1].reload.reports_rejected_count }.to(0)
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
    describe "about users counter cache" do
      let!(:ddfip)  { create(:ddfip) }
      let!(:office) { create(:office, ddfip:) }

      describe "#users_count" do
        let!(:user) { create(:user, organization: ddfip) }

        it "changes when users is assigned to the office" do
          expect { office.users << user }
            .to change { office.reload.users_count }.from(0).to(1)
        end

        it "changes when users is removed from the office" do
          office.users << user

          expect { office.users.delete(user) }
            .to change { office.reload.users_count }.from(1).to(0)
        end

        it "changes when user is discarded" do
          office.users << user

          expect { user.discard }
            .to change { office.reload.users_count }.from(1).to(0)
        end

        it "changes when is undiscarded" do
          office.users << user
          user.discard

          expect { user.undiscard }
            .to change { office.reload.users_count }.from(0).to(1)
        end

        it "changes when users is destroyed" do
          office.users << user

          expect { user.destroy }
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

      describe "#reports_assigned_count" do
        let(:office) { create(:office, :with_communes, ddfip:) }
        let(:report) { create(:report, :transmitted, :made_for_office, office:) }

        it "doesn't change when report is created" do
          expect { report }
            .not_to change { office.reload.reports_assigned_count }.from(0)
        end

        it "changes when report is assigned" do
          report

          expect { report.package.assign! }
            .to change { office.reload.reports_assigned_count }.from(0).to(1)
        end

        it "changes when assigned report is discarded" do
          report.package.assign!

          expect { report.discard }
            .to change { office.reload.reports_assigned_count }.from(1).to(0)
        end

        it "changes when assigned report is undiscarded" do
          report.package.assign!
          report.discard

          expect { report.undiscard }
            .to change { office.reload.reports_assigned_count }.from(0).to(1)
        end

        it "changes when assigned report is deleted" do
          report.package.assign!

          expect { report.delete }
            .to change { office.reload.reports_assigned_count }.from(1).to(0)
        end

        it "doesn't changes when report is debated" do
          report.package.assign!

          expect { report.debate! }
            .not_to change { office.reload.reports_assigned_count }.from(1)
        end

        it "doesn't changes when report is approved" do
          report.package.assign!

          expect { report.approve! }
            .not_to change { office.reload.reports_assigned_count }.from(1)
        end

        it "doesn't changes when report is rejected" do
          report.package.assign!

          expect { report.reject! }
            .not_to change { office.reload.reports_assigned_count }.from(1)
        end
      end

      describe "#reports_pending_count" do
        let(:office) { create(:office, :with_communes, ddfip:) }
        let(:report) { create(:report, :transmitted, :made_for_office, office:) }

        it "doesn't change when report is created" do
          expect { report }
            .not_to change { office.reload.reports_pending_count }.from(0)
        end

        it "changes when report is assigned" do
          report

          expect { report.package.assign! }
            .to change { office.reload.reports_pending_count }.from(0).to(1)
        end

        it "changes when report is debated" do
          report.package.assign!

          expect { report.debate! }
            .to change { office.reload.reports_pending_count }.from(1).to(0)
        end

        it "changes when report is approved" do
          report.package.assign!

          expect { report.approve! }
            .to change { office.reload.reports_pending_count }.from(1).to(0)
        end

        it "changes when report is rejected" do
          report.package.assign!

          expect { report.reject! }
            .to change { office.reload.reports_pending_count }.from(1).to(0)
        end
      end

      describe "#reports_debated_count" do
        let(:office) { create(:office, :with_communes, ddfip:) }
        let(:report) { create(:report, :assigned_to_office, office:) }

        it "doesn't change when package is assigned" do
          expect { report }
            .not_to change { office.reload.reports_debated_count }.from(0)
        end

        it "doesn't changes when report is approved" do
          report

          expect { report.approve! }
            .not_to change { office.reload.reports_debated_count }.from(0)
        end

        it "doesn't changes when report is rejected" do
          report

          expect { report.reject! }
            .not_to change { office.reload.reports_debated_count }.from(0)
        end

        it "changes when report is debated" do
          report

          expect { report.debate! }
            .to change { office.reload.reports_debated_count }.from(0).to(1)
        end

        it "changes when debated report is reseted" do
          report.debate!

          expect { report.update(debated_at: nil) }
            .to change { office.reload.reports_debated_count }.from(1).to(0)
        end

        it "changes when debated report is approved" do
          report.debate!

          expect { report.approve! }
            .to change { office.reload.reports_debated_count }.from(1).to(0)
        end

        it "changes when debated report is rejected" do
          report.debate!

          expect { report.reject! }
            .to change { office.reload.reports_debated_count }.from(1).to(0)
        end
      end

      describe "#reports_approved_count" do
        let(:office) { create(:office, :with_communes, ddfip:) }
        let(:report) { create(:report, :assigned_to_office, office:) }

        it "doesn't change when package is assigned" do
          expect { report }
            .not_to change { office.reload.reports_approved_count }.from(0)
        end

        it "doesn't changes when report is rejected" do
          report

          expect { report.reject! }
            .not_to change { office.reload.reports_approved_count }.from(0)
        end

        it "doesn't changes when report is debated" do
          report

          expect { report.debate! }
            .not_to change { office.reload.reports_approved_count }.from(0)
        end

        it "changes when report is approved" do
          report

          expect { report.approve! }
            .to change { office.reload.reports_approved_count }.from(0).to(1)
        end

        it "changes when approved report is reseted" do
          report.approve!

          expect { report.update(approved_at: nil) }
            .to change { office.reload.reports_approved_count }.from(1).to(0)
        end

        it "changes when approved report is rejected" do
          report.approve!

          expect { report.reject! }
            .to change { office.reload.reports_approved_count }.from(1).to(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:office) { create(:office, :with_communes, ddfip:) }
        let(:report) { create(:report, :assigned_to_office, office:) }

        it "doesn't change when package is assigned" do
          expect { report }
            .not_to change { office.reload.reports_rejected_count }.from(0)
        end

        it "doesn't changes when report is approved" do
          report

          expect { report.approve! }
            .not_to change { office.reload.reports_rejected_count }.from(0)
        end

        it "doesn't changes when report is debated" do
          report

          expect { report.debate! }
            .not_to change { office.reload.reports_rejected_count }.from(0)
        end

        it "changes when report is rejected" do
          report

          expect { report.reject! }
            .to change { office.reload.reports_rejected_count }.from(0).to(1)
        end

        it "changes when rejected report is reseted" do
          report.reject!

          expect { report.update(rejected_at: nil) }
            .to change { office.reload.reports_rejected_count }.from(1).to(0)
        end

        it "changes when rejected report is approved" do
          report.reject!

          expect { report.approve! }
            .to change { office.reload.reports_rejected_count }.from(1).to(0)
        end
      end
    end
  end
end
