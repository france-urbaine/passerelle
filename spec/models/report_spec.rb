# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:package).required }
    it { is_expected.to belong_to(:workshop).optional }
    it { is_expected.to belong_to(:commune).optional }

    it { is_expected.to have_many(:siblings) }

    it { is_expected.to have_many(:potential_office_communes) }
    it { is_expected.to have_many(:potential_offices) }
    it { is_expected.to have_many(:offices) }
  end

  # Attachments
  # ----------------------------------------------------------------------------
  describe "attachments" do
    it { is_expected.to have_many_attached(:images) }
    it { is_expected.to have_many_attached(:documents) }
  end

  # Database constraints
  # ----------------------------------------------------------------------------
  describe "database contraints" do
    let_it_be(:report) { create(:report, action: "evaluation_hab") }

    it "asserts uniqueness of action per local" do
      pending "TODO"
      expect {
        create(:report)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "asserts an action is allowed by not triggering DB constraints" do
      expect {
        report.update_column(:action, "evaluation_eco")
      }.not_to raise_error
    end

    it "asserts an action is not allowed by triggering DB constraints" do
      expect {
        report.update_column(:action, "evaluation_cfe")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "asserts a priority is allowed by not triggering DB constraints" do
      expect {
        report.update_column(:priority, "high")
      }.not_to raise_error
    end

    it "asserts a priority is not allowed by triggering DB constraints" do
      expect {
        report.update_column(:priority, "higher")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:subject) }

    it { is_expected.to validate_inclusion_of(:action).in_array(Report::ACTIONS) }
    it { is_expected.to validate_inclusion_of(:subject).in_array(Report::SUBJECTS) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w[low medium high]) }
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes reports tagged as sandbox by publishers" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."sandbox" = TRUE
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes reports from transmitted packages" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
        SQL
      end
    end

    describe ".published" do
      it "scopes on transmitted reports, not discarded and not tagged as sandbox" do
        expect {
          described_class.published.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
        SQL
      end
    end

    describe ".pending" do
      it "scopes on published reports waiting for decision" do
        expect {
          described_class.pending.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "reports"."approved_at" IS NULL
            AND      "reports"."rejected_at" IS NULL
            AND      "reports"."debated_at" IS NULL
        SQL
      end
    end

    describe ".approved" do
      it "scopes on approved reports" do
        expect {
          described_class.approved.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "reports"."approved_at" IS NOT NULL
        SQL
      end
    end

    describe ".rejected" do
      it "scopes on rejected reports" do
        expect {
          described_class.rejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "reports"."rejected_at" IS NOT NULL
        SQL
      end
    end

    describe ".debated" do
      it "scopes on debated reports" do
        expect {
          described_class.debated.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "reports"."debated_at" IS NOT NULL
        SQL
      end
    end

    describe ".sent_by_collectivity" do
      it "scopes on reports sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on reports sent by many collectivities" do
        expect {
          described_class.sent_by_collectivity(Collectivity.where(name: "A")).load
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

    describe ".sent_by_publisher" do
      it "scopes on reports sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on reports sent by many publishers" do
        expect {
          described_class.sent_by_publisher(Publisher.where(name: "A")).load
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

    describe ".sent_by" do
      it "scopes on reports sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by(collectivity).load
        }.to send_message(described_class, :sent_by_collectivity).with(collectivity)
      end

      it "scopes on reports sent by many collectivities" do
        collectivities = Collectivity.where(name: "A")

        expect {
          described_class.sent_by(collectivities).load
        }.to send_message(described_class, :sent_by_collectivity).with(collectivities)
      end

      it "scopes on reports sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by(publisher).load
        }.to send_message(described_class, :sent_by_publisher).with(publisher)
      end

      it "scopes on reports sent by many publishers" do
        publishers = Publisher.where(name: "A")

        expect {
          described_class.sent_by(publishers).load
        }.to send_message(described_class, :sent_by_publisher).with(publishers)
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.sent_by(User.all).load
        }.to raise_error(TypeError)
      end
    end

    describe ".located_in" do
      it "scopes on reports located in one single commune" do
        commune = create(:commune, code_insee: "64102")

        expect {
          described_class.located_in(commune).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."code_insee" = '64102'
        SQL
      end

      it "scopes on reports located in many communes" do
        expect {
          described_class.located_in(Commune.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."code_insee" IN (
            SELECT "communes"."code_insee"
            FROM   "communes"
            WHERE  "communes"."name" = 'A'
          )
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
        office = create(:office, action: "evaluation_hab")

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."action" = 'evaluation_hab'
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
            AND      "reports"."action" = "offices"."action"
        SQL
      end
    end

    describe ".covered_by" do
      it "scopes reports covered by one single DDFIP" do
        ddfip = create(:ddfip)

        expect {
          described_class.covered_by(ddfip).load
        }.to send_message(described_class, :covered_by_ddfip).with(ddfip)
      end

      it "scopes reports covered by many DDFIPs" do
        ddfips = DDFIP.where(name: "A")

        expect {
          described_class.covered_by(ddfips).load
        }.to send_message(described_class, :covered_by_ddfip).with(ddfips)
      end

      it "scopes reports covered by one single office" do
        office = create(:office)

        expect {
          described_class.covered_by(office).load
        }.to send_message(described_class, :covered_by_office).with(office)
      end

      it "scopes reports covered by many offices" do
        offices = Office.where(name: "A")

        expect {
          described_class.covered_by(offices).load
        }.to send_message(described_class, :covered_by_office).with(offices)
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.covered_by(User.all).load
        }.to raise_error(TypeError)
      end
    end

    describe ".available_to_publisher" do
      it "scopes reports available to a publisher" do
        publisher = create(:publisher)

        expect {
          described_class.available_to_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."publisher_id" = '#{publisher.id}'
        SQL
      end
    end

    describe ".available_to_collectivity" do
      it "scopes reports available to a collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.available_to_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "reports"."collectivity_id" = '#{collectivity.id}'
            AND      ("packages"."transmitted_at" IS NOT NULL OR "packages"."publisher_id" IS NULL)
        SQL
      end
    end

    describe ".available_to_ddfip" do
      it "scopes reports available to a ddfip" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.available_to_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "communes"."code_departement" = '64'
            AND      "packages"."discarded_at" IS NULL
            AND      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".available_to_office" do
      it "scopes reports available to a office" do
        office = create(:office, action: "evaluation_hab")

        expect {
          described_class.available_to_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "reports"."discarded_at" IS NULL
            AND      "reports"."sandbox" = FALSE
            AND      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."action" = 'evaluation_hab'
            AND      "packages"."discarded_at" IS NULL
            AND      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."approved_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".available_to" do
      it "scopes reports available to a publisher" do
        publisher = create(:publisher)

        expect {
          described_class.available_to(publisher).load
        }.to send_message(described_class, :available_to_publisher).with(publisher)
      end

      it "scopes reports available to a collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.available_to(collectivity).load
        }.to send_message(described_class, :available_to_collectivity).with(collectivity)
      end

      it "scopes reports available to a ddfip" do
        ddfip = create(:ddfip)

        expect {
          described_class.available_to(ddfip).load
        }.to send_message(described_class, :available_to_ddfip).with(ddfip)
      end

      it "scopes reports available to a office" do
        office = create(:office)

        expect {
          described_class.available_to(office).load
        }.to send_message(described_class, :available_to_office).with(office)
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.available_to(User.all).load
        }.to raise_error(TypeError)
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    # Use only one collectivity to reduce the number of queries and records to create
    let_it_be(:collectivity) { build(:collectivity) }
    let_it_be(:packages) do
      [
        build(:package, collectivity: collectivity),
        build(:package, :transmitted,         collectivity: collectivity),
        build(:package, :rejected,            collectivity: collectivity),
        build(:package, :approved, :rejected, collectivity: collectivity),
        build(:package, :approved,            collectivity: collectivity)
      ]
    end

    let_it_be(:reports) do
      [
        build(:report, package: packages[0]),                 # 0
        build(:report, package: packages[1]),                 # 1
        build(:report, package: packages[1], sandbox: true),  # 2
        build(:report, package: packages[2]),                 # 3
        build(:report, package: packages[3]),                 # 4
        build(:report, package: packages[4]),                 # 5
        build(:report, :discarded, package: packages[4]),     # 6
        build(:report, :approved,  package: packages[4]),     # 7
        build(:report, :rejected,  package: packages[4]),     # 8
        build(:report, :debated,   package: packages[4])      # 9
      ]
    end

    describe "#transmitted?" do
      it { expect(reports[0]).not_to be_transmitted }
      it { expect(reports[1..]).to all(be_transmitted) }
    end

    describe "#published?" do
      it { expect(reports[0]).not_to be_published }
      it { expect(reports[1]).to     be_published }
      it { expect(reports[2]).not_to be_published }
      it { expect(reports[3]).to     be_published }
      it { expect(reports[4]).to     be_published }
      it { expect(reports[5]).to     be_published }
      it { expect(reports[6]).not_to be_published }
      it { expect(reports[7]).to     be_published }
      it { expect(reports[8]).to     be_published }
      it { expect(reports[9]).to     be_published }
    end

    describe "#pending?" do
      it { expect(reports[5]).to     be_pending }
      it { expect(reports[6]).not_to be_pending }
      it { expect(reports[7]).not_to be_pending }
      it { expect(reports[8]).not_to be_pending }
      it { expect(reports[9]).not_to be_pending }
    end

    describe "#approved?" do
      it { expect(reports[5]).not_to be_approved }
      it { expect(reports[6]).not_to be_approved }
      it { expect(reports[7]).to     be_approved }
      it { expect(reports[8]).not_to be_approved }
      it { expect(reports[9]).not_to be_approved }
    end

    describe "#rejected?" do
      it { expect(reports[5]).not_to be_rejected }
      it { expect(reports[6]).not_to be_rejected }
      it { expect(reports[7]).not_to be_rejected }
      it { expect(reports[8]).to     be_rejected }
      it { expect(reports[9]).not_to be_rejected }
    end

    describe "#debated?" do
      it { expect(reports[5]).not_to be_debated }
      it { expect(reports[6]).not_to be_debated }
      it { expect(reports[7]).not_to be_debated }
      it { expect(reports[8]).not_to be_debated }
      it { expect(reports[9]).to     be_debated }
    end
  end
end
