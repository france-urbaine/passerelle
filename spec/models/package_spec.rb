# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:transmission).optional }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_presence_of(:form_type) }
    it { is_expected.to validate_inclusion_of(:form_type).in_array(Report::FORM_TYPES) }

    it "validates uniqueness of :reference" do
      create(:package)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates uniqueness of :reference against discarded records" do
      create(:package, :discarded)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes packages tagged as sandbox" do
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
      it "scopes packages by excluding those tagged as sandbox" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes on transmitted packages (not in sandbox)" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".unresolved" do
      it "scopes on packages waiting to be assigned or returned" do
        expect {
          described_class.unresolved.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."assigned_at" IS NULL
            AND  "packages"."returned_at" IS NULL
        SQL
      end
    end

    describe ".missed" do
      it "scopes on packages not seen by DDFIP admins" do
        pending "not yet implemented"

        expect {
          described_class.missed.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."acknowledged_at" IS NULL
        SQL
      end
    end

    describe ".acknowledged" do
      it "scopes on packages seen by DDFIP admins but not yet resolved" do
        pending "not yet implemented"

        expect {
          described_class.acknowledged.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."acknowledged_at" IS NOT NULL
        SQL
      end
    end

    describe ".assigned" do
      it "scopes on packages assigned by a DDFIP" do
        expect {
          described_class.assigned.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."assigned_at" IS NOT NULL
            AND  "packages"."returned_at" IS NULL
        SQL
      end
    end

    describe ".returned" do
      it "scopes on packages returned by a DDFIP" do
        expect {
          described_class.returned.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."returned_at" IS NOT NULL
        SQL
      end
    end

    describe ".unreturned" do
      it "scopes on packages not returned by a DDFIP" do
        expect {
          described_class.unreturned.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
            AND  "packages"."returned_at" IS NULL
        SQL
      end
    end

    describe ".made_through_publisher_api" do
      it "scopes on packages made through publisher API" do
        expect {
          described_class.made_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".made_through_web_ui" do
      it "scopes on packages made byt the collectivity through web UI" do
        expect {
          described_class.made_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".made_by_collectivity" do
      it "scopes on packages made by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.made_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on packages made by many collectivities" do
        expect {
          described_class.made_by_collectivity(Collectivity.where(name: "A")).load
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

    describe ".made_by_publisher" do
      it "scopes on packages made by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.made_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on packages made by many publishers" do
        expect {
          described_class.made_by_publisher(Publisher.where(name: "A")).load
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
  describe "predicates methods" do
    let_it_be(:publisher)      { build_stubbed(:publisher) }
    let_it_be(:collectivities) { build_stubbed_list(:collectivity, 2, publisher: publisher) }
    let_it_be(:packages) do
      collectivity = collectivities[0]

      [
        build_stubbed(:package, collectivity:),                                         # 0
        build_stubbed(:package, collectivity:, publisher:),                             # 1
        build_stubbed(:package, :sandbox, collectivity:, publisher:),                   # 2
        build_stubbed(:package, :assigned, collectivity:),                              # 3
        build_stubbed(:package, :returned, collectivity:),                              # 4
        build_stubbed(:package, :assigned, :returned, collectivity: collectivities[1]), # 5
        build(:package, collectivity:),                                                 # 6
        build(:package, collectivity: collectivities[1], publisher:)                    # 7
      ]
    end

    describe "#out_of_sandbox?" do
      it { expect(packages[0]).to     be_out_of_sandbox }
      it { expect(packages[1]).to     be_out_of_sandbox }
      it { expect(packages[2]).not_to be_out_of_sandbox }
      it { expect(packages[3]).to     be_out_of_sandbox }
      it { expect(packages[4]).to     be_out_of_sandbox }
      it { expect(packages[5]).to     be_out_of_sandbox }
    end

    describe "#transmitted?" do
      it { expect(packages[0]).to     be_transmitted }
      it { expect(packages[1]).to     be_transmitted }
      it { expect(packages[2]).not_to be_transmitted }
      it { expect(packages[3]).to     be_transmitted }
      it { expect(packages[4]).to     be_transmitted }
      it { expect(packages[5]).to     be_transmitted }
    end

    describe "#unresolved?" do
      it { expect(packages[0]).to     be_unresolved }
      it { expect(packages[1]).to     be_unresolved }
      it { expect(packages[2]).not_to be_unresolved }
      it { expect(packages[3]).not_to be_unresolved }
      it { expect(packages[4]).not_to be_unresolved }
      it { expect(packages[5]).not_to be_unresolved }
    end

    describe "#missed?" do
      pending "Not yet implemented"
    end

    describe "#acknowledged?" do
      pending "Not yet implemented"
    end

    describe "#assigned?" do
      it { expect(packages[0]).not_to be_assigned }
      it { expect(packages[1]).not_to be_assigned }
      it { expect(packages[2]).not_to be_assigned }
      it { expect(packages[3]).to     be_assigned }
      it { expect(packages[4]).not_to be_assigned }
      it { expect(packages[5]).not_to be_assigned }
    end

    describe "#returned?" do
      it { expect(packages[0]).not_to be_returned }
      it { expect(packages[1]).not_to be_returned }
      it { expect(packages[2]).not_to be_returned }
      it { expect(packages[3]).not_to be_returned }
      it { expect(packages[4]).to     be_returned }
      it { expect(packages[5]).to     be_returned }
    end

    describe "#unreturned?" do
      it { expect(packages[0]).to     be_unreturned }
      it { expect(packages[1]).to     be_unreturned }
      it { expect(packages[2]).not_to be_unreturned }
      it { expect(packages[3]).to     be_unreturned }
      it { expect(packages[4]).not_to be_unreturned }
      it { expect(packages[5]).not_to be_unreturned }
    end

    describe "#made_through_publisher_api?" do
      it { expect(packages[0]).not_to be_made_through_publisher_api }
      it { expect(packages[1]).to     be_made_through_publisher_api }
      it { expect(packages[6]).not_to be_made_through_publisher_api }
      it { expect(packages[7]).to     be_made_through_publisher_api }
    end

    describe "#made_through_web_ui?" do
      it { expect(packages[0]).to     be_made_through_web_ui }
      it { expect(packages[1]).not_to be_made_through_web_ui }
      it { expect(packages[6]).to     be_made_through_web_ui }
      it { expect(packages[7]).not_to be_made_through_web_ui }
    end

    describe "#made_by_collectivity?" do
      it { expect(packages[0]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[1]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[6]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[7]).not_to be_made_by_collectivity(collectivities[0]) }
    end

    describe "#made_by_publisher?" do
      it { expect(packages[0]).not_to be_made_by_publisher(publisher) }
      it { expect(packages[1]).to     be_made_by_publisher(publisher) }
      it { expect(packages[6]).not_to be_made_by_publisher(publisher) }
      it { expect(packages[7]).to     be_made_by_publisher(publisher) }
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe "#assign!" do
      it "returns true" do
        package = create(:package)

        expect(package.assign!).to be(true)
      end

      it "returns true when package was already assigned" do
        package = create(:package, :assigned)

        expect(package.assign!).to be(true)
      end

      it "marks the package as assigned" do
        package = create(:package)

        expect {
          package.assign!
          package.reload
        }.to change(package, :assigned_at).to(be_present)
      end

      it "resets return time" do
        package = create(:package, :returned)

        expect {
          package.assign!
          package.reload
        }.to change(package, :returned_at).to(nil)
      end

      it "doesn't update previous approval time" do
        package = Timecop.freeze(2.minutes.ago) do
          create(:package, :assigned)
        end

        expect {
          package.assign!
          package.reload
        }.not_to change(package, :assigned_at)
      end
    end

    describe "#return!" do
      it "returns true" do
        package = create(:package)

        expect(package.return!).to be(true)
      end

      it "returns true when package was already returned" do
        package = create(:package, :returned)

        expect(package.return!).to be(true)
      end

      it "marks the package as assigned" do
        package = create(:package)

        expect {
          package.return!
          package.reload
        }.to change(package, :returned_at).to(be_present)
      end

      it "reset approval time" do
        package = create(:package, :assigned)

        expect {
          package.return!
          package.reload
        }.to change(package, :assigned_at).to(nil)
      end

      it "doesn't update previous return time" do
        package = Timecop.freeze(2.minutes.ago) do
          create(:package, :returned)
        end

        expect {
          package.return!
          package.reload
        }.not_to change(package, :returned_at)
      end
    end

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

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of reference" do
      existing_package = create(:package, reference: "2023-05-0003")
      another_package  = build(:package, reference: existing_package.reference)

      expect { another_package.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "asserts a form_type is allowed by not triggering DB constraints" do
      package = build(:package, form_type: "evaluation_local_habitation")

      expect { package.save(validate: false) }
        .not_to raise_error
    end

    it "asserts a form_type is not allowed by triggering DB constraints" do
      package = build(:package, form_type: "foo")

      expect { package.save(validate: false) }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end
  end

  describe "database triggers" do
    describe "about reports counters caches", skip: "FIXME" do
      let!(:collectivity) { create(:collectivity) }
      let!(:packages)     { create_list(:package, 2, collectivity: collectivity) }

      describe "#reports_count" do
        let(:report) { build(:report, package: packages[0]) }

        it "changes on creation" do
          expect { report.save! }
            .to change { packages[0].reload.reports_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_count }.from(0)
        end

        it "changes when report is assigned to another package" do
          report.save!

          expect { report.update_columns(package_id: packages[1].id) }
            .to  change { packages[0].reload.reports_count }.from(1).to(0)
            .and change { packages[1].reload.reports_count }.from(0).to(1)
        end

        it "changes on deletion" do
          report.save!

          expect { report.destroy }
            .to change { packages[0].reload.reports_count }.from(1).to(0)
            .and not_change { packages[1].reload.reports_count }.from(0)
        end
      end

      describe "#reports_completed_count" do
        let(:report) { build(:report, package: packages[0]) }

        it "doesn't changes on creation" do
          expect { report.save! }
            .to  not_change { packages[0].reload.reports_completed_count }.from(0)
            .and not_change { packages[1].reload.reports_completed_count }.from(0)
        end

        it "changes on creation when report is already completed" do
          report.completed_at = Time.current

          expect { report.save! }
            .to change { packages[0].reload.reports_completed_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_completed_count }.from(0)
        end

        it "changes when report is completed" do
          report.save!

          expect { report.update_columns(completed_at: Time.current) }
            .to change { packages[0].reload.reports_completed_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_completed_count }.from(0)
        end

        it "changes when completed report is deleted" do
          report.completed_at = Time.current
          report.save!

          expect { report.delete }
            .to change { packages[0].reload.reports_completed_count }.from(1).to(0)
            .and not_change { packages[1].reload.reports_completed_count }.from(0)
        end
      end

      describe "#reports_approved_count" do
        let(:report) { build(:report, package: packages[0]) }

        it "doesn't changes on creation" do
          expect { report.save! }
            .to  not_change { packages[0].reload.reports_approved_count }.from(0)
            .and not_change { packages[1].reload.reports_approved_count }.from(0)
        end

        it "changes on creation when report is already approved" do
          report.approved_at = Time.current

          expect { report.save! }
            .to change { packages[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_approved_count }.from(0)
        end

        it "changes when report is approved" do
          report.save!

          expect { report.update_columns(approved_at: Time.current) }
            .to change { packages[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is deleted" do
          report.approved_at = Time.current
          report.save!

          expect { report.delete }
            .to change { packages[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { packages[1].reload.reports_approved_count }.from(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:report) { create(:report, package: packages[0]) }

        it "doesn't changes on creation" do
          expect { report.save! }
            .to  not_change { packages[0].reload.reports_rejected_count }.from(0)
            .and not_change { packages[1].reload.reports_rejected_count }.from(0)
        end

        it "changes on creation when report is already rejected" do
          report.rejected_at = Time.current

          expect { report.save! }
            .to change { packages[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when report is rejected" do
          report.save!

          expect { report.update_columns(rejected_at: Time.current) }
            .to change { packages[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is deleted" do
          report.rejected_at = Time.current
          report.save!

          expect { report.delete }
            .to change { packages[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { packages[1].reload.reports_rejected_count }.from(0)
        end
      end

      describe "#reports_debated_count" do
        let(:report) { create(:report, package: packages[0]) }

        it "doesn't changes on creation" do
          expect { report.save! }
            .to  not_change { packages[0].reload.reports_debated_count }.from(0)
            .and not_change { packages[1].reload.reports_debated_count }.from(0)
        end

        it "changes on creation when report is already debated" do
          report.debated_at = Time.current

          expect { report.save! }
            .to change { packages[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_debated_count }.from(0)
        end

        it "changes when report is debated" do
          report.save!

          expect { report.update_columns(debated_at: Time.current) }
            .to change { packages[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { packages[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is deleted" do
          report.debated_at = Time.current
          report.save!

          expect { report.delete }
            .to change { packages[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { packages[1].reload.reports_debated_count }.from(0)
        end
      end
    end
  end
end
