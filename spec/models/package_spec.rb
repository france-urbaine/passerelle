# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:action).in_array(Report::ACTIONS) }
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes packages not yet transmitted" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = TRUE
        SQL
      end
    end

    describe ".out_of_sandbox" do
      it "scopes packages not yet transmitted" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".packing" do
      it "scopes packages not yet transmitted" do
        expect {
          described_class.packing.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NULL
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes on transmitted packages" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
        SQL
      end
    end

    describe ".to_approve" do
      it "scopes on transmitted and undiscarded packages waiting for approval" do
        expect {
          described_class.to_approve.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."discarded_at" IS NULL
            AND  "packages"."approved_at" IS NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".approved" do
      it "scopes on packages approved by a DDFIP" do
        expect {
          described_class.approved.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."approved_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".rejected" do
      it "scopes on packages rejected by a DDFIP" do
        expect {
          described_class.rejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NOT NULL
        SQL
      end
    end

    describe ".unrejected" do
      it "scopes on packages rejected by a DDFIP" do
        expect {
          described_class.unrejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".packed_through_publisher_api" do
      it "scopes on packages packed through publisher API" do
        expect {
          described_class.packed_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".packed_through_web_ui" do
      it "scopes on packages packed byt the collectivity through web UI" do
        expect {
          described_class.packed_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".sent_by_collectivity" do
      it "scopes on packages sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on packages sent by many collectivities" do
        expect {
          described_class.sent_by_collectivity(Collectivity.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" IN (
            SELECT "collectivities"."id"
            FROM   "collectivities"
            WHERE  "collectivities"."name" = 'A'
          )
        SQL
      end
    end

    describe ".sent_by_publisher" do
      it "scopes on packages sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on packages sent by many publishers" do
        expect {
          described_class.sent_by_publisher(Publisher.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IN (
            SELECT "publishers"."id"
            FROM   "publishers"
            WHERE  "publishers"."name" = 'A'
          )
        SQL
      end
    end

    describe ".with_reports" do
      it "scopes on packages having kept reports" do
        expect {
          described_class.with_reports.load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          WHERE      "reports"."discarded_at" IS NULL
        SQL
      end

      it "scopes on packages having the expected reports (overriding default kept reports)" do
        expect {
          described_class.with_reports(Report.where(code_insee: "64102")).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          WHERE      "reports"."code_insee" = '64102'
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    let_it_be(:publisher)      { build_stubbed(:publisher) }
    let_it_be(:collectivities) { build_stubbed_list(:collectivity, 2, publisher: publisher) }
    let_it_be(:packages) do
      [
        build_stubbed(:package, collectivity: collectivities[0]),
        build_stubbed(:package, :transmitted, collectivity: collectivities[0], publisher: publisher),
        build_stubbed(:package, :approved, collectivity: collectivities[0]),
        build_stubbed(:package, :rejected, collectivity: collectivities[0]),
        build_stubbed(:package, :approved, :rejected, collectivity: collectivities[1]),
        build_stubbed(:package, :transmitted, collectivity: collectivities[0], publisher: publisher, sandbox: true),
        build(:package, collectivity: collectivities[0]),
        build(:package, collectivity: collectivities[1], publisher: publisher)
      ]
    end

    describe "#out_of_sandbox?" do
      it { expect(packages[0]).to be_out_of_sandbox }
      it { expect(packages[1]).to be_out_of_sandbox }
      it { expect(packages[2]).to be_out_of_sandbox }
      it { expect(packages[3]).to be_out_of_sandbox }
      it { expect(packages[4]).to be_out_of_sandbox }
      it { expect(packages[5]).not_to be_out_of_sandbox }
    end

    describe "#packing?" do
      it { expect(packages[0]).to be_packing }
      it { expect(packages[1]).not_to be_packing }
      it { expect(packages[2]).not_to be_packing }
      it { expect(packages[3]).not_to be_packing }
      it { expect(packages[4]).not_to be_packing }
    end

    describe "#transmitted?" do
      it { expect(packages[0]).not_to be_transmitted }
      it { expect(packages[1]).to be_transmitted }
      it { expect(packages[2]).to be_transmitted }
      it { expect(packages[3]).to be_transmitted }
      it { expect(packages[4]).to be_transmitted }
    end

    describe "#to_approve?" do
      it { expect(packages[0]).not_to be_to_approve }
      it { expect(packages[1]).to be_to_approve }
      it { expect(packages[2]).not_to be_to_approve }
      it { expect(packages[3]).not_to be_to_approve }
      it { expect(packages[4]).not_to be_to_approve }
    end

    describe "#approved?" do
      it { expect(packages[0]).not_to be_approved }
      it { expect(packages[1]).not_to be_approved }
      it { expect(packages[2]).to be_approved }
      it { expect(packages[3]).not_to be_approved }
      it { expect(packages[4]).not_to be_approved }
    end

    describe "#rejected?" do
      it { expect(packages[0]).not_to be_rejected }
      it { expect(packages[1]).not_to be_rejected }
      it { expect(packages[2]).not_to be_rejected }
      it { expect(packages[3]).to be_rejected }
      it { expect(packages[4]).to be_rejected }
    end

    describe "#unrejected?" do
      it { expect(packages[0]).not_to be_unrejected }
      it { expect(packages[1]).to be_unrejected }
      it { expect(packages[2]).to be_unrejected }
      it { expect(packages[3]).not_to be_unrejected }
      it { expect(packages[4]).not_to be_unrejected }
    end

    describe "#packed_through_publisher_api?" do
      it { expect(packages[0]).not_to be_packed_through_publisher_api }
      it { expect(packages[1]).to     be_packed_through_publisher_api }
      it { expect(packages[6]).not_to be_packed_through_publisher_api }
      it { expect(packages[7]).to     be_packed_through_publisher_api }
    end

    describe "#packed_through_web_ui?" do
      it { expect(packages[0]).to     be_packed_through_web_ui }
      it { expect(packages[1]).not_to be_packed_through_web_ui }
      it { expect(packages[6]).to     be_packed_through_web_ui }
      it { expect(packages[7]).not_to be_packed_through_web_ui }
    end

    describe "#sent_by_collectivity?" do
      it { expect(packages[0]).to     be_sent_by_collectivity(collectivities[0]) }
      it { expect(packages[1]).to     be_sent_by_collectivity(collectivities[0]) }
      it { expect(packages[6]).to     be_sent_by_collectivity(collectivities[0]) }
      it { expect(packages[7]).not_to be_sent_by_collectivity(collectivities[0]) }
    end

    describe "#sent_by_publisher?" do
      it { expect(packages[0]).not_to be_sent_by_publisher(publisher) }
      it { expect(packages[1]).to     be_sent_by_publisher(publisher) }
      it { expect(packages[6]).not_to be_sent_by_publisher(publisher) }
      it { expect(packages[7]).to     be_sent_by_publisher(publisher) }
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    let_it_be(:package) do
      create(:package, action: "evaluation_hab", reference: "2023-05-0003")
    end

    it "asserts the uniqueness of reference" do
      expect {
        create(:package, reference: "2023-05-0003")
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "asserts an action is allowed by not triggering DB constraints" do
      expect {
        package.update_column(:action, "evaluation_pro")
      }.not_to raise_error
    end

    it "asserts an action is not allowed by triggering DB constraints" do
      expect {
        package.update_column(:action, "evaluation_cfe")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe "database triggers" do
    pending "TODO"
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let_it_be(:packages) { create_list(:package, 2) }

    describe "#reports_count" do
      let(:report) { create(:report, package: packages[0]) }

      it "changes on creation" do
        expect { report }
          .to      change { packages[0].reload.reports_count }.from(0).to(1)
          .and not_change { packages[1].reload.reports_count }.from(0)
      end

      it "changes when report is assigned to another package" do
        report
        expect { report.update(package_id: packages[1].id) }
          .to  change { packages[0].reload.reports_count }.from(1).to(0)
          .and change { packages[1].reload.reports_count }.from(0).to(1)
      end

      it "changes on deletion" do
        report
        expect { report.destroy }
          .to      change { packages[0].reload.reports_count }.from(1).to(0)
          .and not_change { packages[1].reload.reports_count }.from(0)
      end
    end

    describe "#reports_completed_count" do
      let(:completed_report) { create(:report, :completed, package: packages[0]) }

      it "changes when report is completed" do
        expect { completed_report }
          .to      change { packages[0].reload.reports_completed_count }.from(0).to(1)
          .and not_change { packages[1].reload.reports_completed_count }.from(0)
      end

      it "changes on deletion" do
        completed_report
        expect { completed_report.destroy }
          .to      change { packages[0].reload.reports_completed_count }.from(1).to(0)
          .and not_change { packages[1].reload.reports_completed_count }.from(0)
      end
    end

    describe "#reports_approved_count" do
      let(:approved_report) { create(:report, :approved, package: packages[0]) }

      it "changes when report is approved" do
        expect { approved_report }
          .to      change { packages[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { packages[1].reload.reports_approved_count }.from(0)
      end

      it "changes on deletion" do
        approved_report
        expect { approved_report.destroy }
          .to      change { packages[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { packages[1].reload.reports_approved_count }.from(0)
      end
    end

    describe "#reports_rejected_count" do
      let(:rejected_report) { create(:report, :rejected, package: packages[0]) }

      it "changes when report is rejected" do
        expect { rejected_report }
          .to      change { packages[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { packages[1].reload.reports_rejected_count }.from(0)
      end

      it "changes on deletion" do
        rejected_report
        expect { rejected_report.destroy }
          .to      change { packages[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { packages[1].reload.reports_rejected_count }.from(0)
      end
    end

    describe "#reports_debated_count" do
      let(:debated_report) { create(:report, :debated, package: packages[0]) }

      it "changes when report is debated" do
        expect { debated_report }
          .to      change { packages[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { packages[1].reload.reports_debated_count }.from(0)
      end

      it "changes on deletion" do
        debated_report
        expect { debated_report.destroy }
          .to      change { packages[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { packages[1].reload.reports_debated_count }.from(0)
      end
    end

    describe "#completed" do
      let(:approved_report) { create(:report, :approved, package: packages[0]) }

      it "changes when reports_count is equal to reports_approved_count" do
        expect { approved_report }
          .to      change { packages[0].reload.completed? }.from(false).to(true)
          .and not_change { packages[1].reload.completed? }.from(false)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:packages) { create_list(:package, 2) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_packages_counters()") }

    describe "on reports_count" do
      before do
        create_list(:report, 2, package: packages[0])

        Package.update_all(reports_count: 0)
      end

      it { expect { reset_all_counters }.to change { packages[0].reload.reports_count }.from(0).to(2) }
      it { expect { reset_all_counters }.to not_change { packages[1].reload.reports_count }.from(0) }
    end
  end
end
