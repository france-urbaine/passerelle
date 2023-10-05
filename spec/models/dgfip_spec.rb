# frozen_string_literal: true

require "rails_helper"

RSpec.describe DGFIP do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates that no other one DGFIP exist on creation" do
      create(:dgfip)

      expect {
        create(:dgfip)
      }.to raise_error(ActiveRecord::RecordInvalid).with_message(/Une instance .+ a déjà été crée/)
    end

    it "cannot create a new DGFIP when another one is discarded" do
      create(:dgfip, :discarded)

      expect {
        create(:dgfip)
      }.to raise_error(ActiveRecord::RecordInvalid).with_message(/Une instance .+ a déjà été crée/)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for DGFIPs with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for DDFIPs by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for DGFIPs with text matching the name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:dgfip) { create(:dgfip) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_dgfips_counters()")
      end

      it "returns the number of concerned collectivities" do
        expect(described_class.reset_all_counters).to eq(1)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: dgfip)
          create(:user, :discarded, organization: dgfip)

          DGFIP.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.users_count }.to(4)
        end
      end

      describe "reports & packages counts" do
        before_all do
          create(:publisher, :with_users, users_size: 1).tap do |publisher|
            create(:collectivity, :with_users, publisher:, users_size: 1).tap do |collectivity|
              create(:package, :with_reports, collectivity:)
              create(:package, :with_reports, :sandbox, collectivity:)
              create(:package, :with_reports, :returned, :with_reports, collectivity:, reports_size: 2)
              create(:package, :with_reports, :assigned, collectivity:).tap do |package|
                create_list(:report, 2, :approved, collectivity:, package:)
                create_list(:report, 3, :rejected, collectivity:, package:)
                create_list(:report, 1, :debated,  collectivity:, package:)
              end
            end
          end

          DGFIP.update_all(
            reports_transmitted_count:  99,
            reports_returned_count:     99,
            reports_pending_count:      99,
            reports_debated_count:      99,
            reports_approved_count:     99,
            reports_rejected_count:     99,
            packages_transmitted_count: 99,
            packages_assigned_count:    99,
            packages_returned_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_transmitted_count }.to(10)
        end

        it "updates #reports_returned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_returned_count }.to(2)
        end

        it "updates #reports_pending_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_pending_count }.to(1)
        end

        it "updates #reports_debated_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_debated_count }.to(1)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_approved_count }.to(2)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_rejected_count }.to(3)
        end

        it "updates #packages_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.packages_transmitted_count }.to(3)
        end

        it "updates #packages_assigned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.packages_assigned_count }.to(1)
        end

        it "updates #packages_returned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.packages_returned_count }.to(1)
        end
      end
    end
  end

  # Singleton record
  # ----------------------------------------------------------------------------
  describe ".find_or_create_singleton_record" do
    it "creates a new record when no other one exists" do
      expect {
        DGFIP.find_or_create_singleton_record
      }.to change(DGFIP, :count).by(1)
    end

    it "assigns default values to new record" do
      dgfip = DGFIP.find_or_create_singleton_record

      expect(dgfip).to have_attributes(name: "Direction générale des Finances publiques")
    end

    it "returns existing record" do
      dgfip = create(:dgfip)

      expect(DGFIP.find_or_create_singleton_record).to eq(dgfip)
    end

    it "undiscard existing but discarded record" do
      dgfip = create(:dgfip, :discarded)

      expect(DGFIP.find_or_create_singleton_record)
        .to eq(dgfip)
        .and be_undiscarded
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of a single record" do
      create(:dgfip)

      expect {
        build(:dgfip).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "doesn't ignore discarded records when asserting the uniqueness of a single record" do
      create(:dgfip, :discarded)

      expect {
        build(:dgfip).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end
  end

  describe "database triggers" do
    let!(:dgfip) { create(:dgfip) }

    describe "#users_count" do
      let(:user) { create(:user, organization: dgfip) }

      it "changes on creation" do
        expect { user }
          .to change { dgfip.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user

        expect { user.destroy }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user

        expect { user.discard }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user.discard

        expect { user.undiscard }
          .to change { dgfip.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user
        ddfip = create(:ddfip)

        expect { user.update(organization: ddfip) }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, collectivity:) }
      let(:report)       { create(:report, collectivity:) }

      it "doesn't change when report is created" do
        expect { report }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report

        expect { report.update(package: package) }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report
        package.update(sandbox: true)

        expect { report.update(package: package) }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when transmitted report is discarded" do
        report.update(package: package)

        expect { report.discard }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report.update(package: package)
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report.update(package: package)

        expect { report.destroy }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when package is discarded" do
        report.update(package: package)

        expect { package.discard }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when package is undiscarded" do
        report.update(package: package)
        package.discard

        expect { package.undiscard }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when package is deleted" do
        report.update(package: package)

        expect { package.delete }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_returned_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, :with_reports, collectivity:, reports_size: 2) }

      it "doesn't change when report are transmitted" do
        expect { package }
          .not_to change { dgfip.reload.reports_returned_count }.from(0)
      end

      it "changes when package is returned" do
        package

        expect { package.return! }
          .to change { dgfip.reload.reports_returned_count }.from(0).to(2)
      end

      it "doesn't change when package is assigned" do
        package

        expect { package.assign! }
          .not_to change { dgfip.reload.reports_returned_count }.from(0)
      end

      it "changes when returned package is then assigned" do
        package.return!

        expect { package.assign! }
          .to change { dgfip.reload.reports_returned_count }.from(2).to(0)
      end

      it "changes when returned package is discarded" do
        package.return!

        expect { package.discard }
          .to change { dgfip.reload.reports_returned_count }.from(2).to(0)
      end

      it "changes when returned package is undiscarded" do
        package.return!
        package.discard

        expect { package.undiscard }
          .to change { dgfip.reload.reports_returned_count }.from(0).to(2)
      end

      it "changes when returned package is deleted" do
        package.return!

        expect { package.delete }
          .to change { dgfip.reload.reports_returned_count }.from(2).to(0)
      end
    end

    describe "#reports_pending_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, :with_reports, collectivity:, reports_size: 2) }

      it "doesn't change when reports are transmitted" do
        expect { package }
          .not_to change { dgfip.reload.reports_pending_count }.from(0)
      end

      it "changes when package is assigned" do
        package

        expect { package.assign! }
          .to change { dgfip.reload.reports_pending_count }.from(0).to(2)
      end

      it "doesn't change when package is returned" do
        package

        expect { package.return! }
          .not_to change { dgfip.reload.reports_pending_count }.from(0)
      end

      it "changes when assigned package is then returned" do
        package.assign!

        expect { package.return! }
          .to change { dgfip.reload.reports_pending_count }.from(2).to(0)
      end

      it "changes when reports are approved" do
        package.assign!

        expect { package.reports.first.approve! }
          .to change { dgfip.reload.reports_pending_count }.from(2).to(1)
      end

      it "changes when reports are rejected" do
        package.assign!

        expect { package.reports.first.reject! }
          .to change { dgfip.reload.reports_pending_count }.from(2).to(1)
      end

      it "changes when reports are debated" do
        package.assign!

        expect { package.reports.first.debate! }
          .to change { dgfip.reload.reports_pending_count }.from(2).to(1)
      end
    end

    describe "#reports_debated_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, :assigned, collectivity:) }
      let(:report)       { create(:report, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { dgfip.reload.reports_debated_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { dgfip.reload.reports_debated_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { dgfip.reload.reports_debated_count }.from(0)
      end

      it "changes when report is debated" do
        report

        expect { report.debate! }
          .to change { dgfip.reload.reports_debated_count }.from(0).to(1)
      end

      it "changes when debated report is reseted" do
        report.debate!

        expect { report.update(debated_at: nil) }
          .to change { dgfip.reload.reports_debated_count }.from(1).to(0)
      end

      it "changes when debated report is approved" do
        report.debate!

        expect { report.approve! }
          .to change { dgfip.reload.reports_debated_count }.from(1).to(0)
      end

      it "changes when debated report is rejected" do
        report.debate!

        expect { report.reject! }
          .to change { dgfip.reload.reports_debated_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, :assigned, collectivity:) }
      let(:report)       { create(:report, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is debated" do
        report

        expect { report.debate! }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report

        expect { report.approve! }
          .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report.approve!

        expect { report.update(approved_at: nil) }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report.approve!

        expect { report.reject! }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, :assigned, collectivity:) }
      let(:report)       { create(:report, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is debated" do
        report

        expect { report.debate! }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report

        expect { report.reject! }
          .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report.reject!

        expect { report.update(rejected_at: nil) }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report.reject!

        expect { report.approve! }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end
    end

    describe "#packages_transmitted_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, collectivity:) }

      it "changes on package creation" do
        expect { package }
          .to change { dgfip.reload.packages_transmitted_count }.from(0).to(1)
      end

      it "doesn't changes when package is created in sandbox" do
        expect { create(:package, collectivity:, sandbox: true) }
          .not_to change { dgfip.reload.packages_transmitted_count }.from(0)
      end

      it "doesn't changes when package switches to sandbox" do
        package

        expect { package.update(sandbox: true) }
          .to change { dgfip.reload.packages_transmitted_count }.from(1).to(0)
      end

      it "doesn't changes when package is assigned" do
        package

        expect { package.assign! }
          .not_to change { dgfip.reload.packages_transmitted_count }.from(1)
      end

      it "doesn't changes when package is returned" do
        package

        expect { package.return! }
          .not_to change { dgfip.reload.packages_transmitted_count }.from(1)
      end

      it "changes when package is discarded" do
        package

        expect { package.discard }
          .to change { dgfip.reload.packages_transmitted_count }.from(1).to(0)
      end

      it "changes when package is undiscarded" do
        package.discard

        expect { package.undiscard }
          .to change { dgfip.reload.packages_transmitted_count }.from(0).to(1)
      end

      it "changes when package is deleted" do
        package

        expect { package.delete }
          .to change { dgfip.reload.packages_transmitted_count }.from(1).to(0)
      end
    end

    describe "#packages_assigned_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, collectivity:) }

      it "doesn't changes on package creation" do
        expect { package }
          .to not_change { dgfip.reload.packages_assigned_count }.from(0)
      end

      it "changes when package is assigned" do
        package

        expect { package.assign! }
          .to change { dgfip.reload.packages_assigned_count }.from(0).to(1)
      end

      it "changes when assigned package is then returned" do
        package.assign!

        expect { package.return! }
          .to change { dgfip.reload.packages_assigned_count }.from(1).to(0)
      end

      it "changes when assigned package is discarded" do
        package.assign!

        expect { package.discard }
          .to change { dgfip.reload.packages_assigned_count }.from(1).to(0)
      end

      it "changes when assigned package is undiscarded" do
        package.assign!
        package.discard

        expect { package.undiscard }
          .to change { dgfip.reload.packages_assigned_count }.from(0).to(1)
      end

      it "changes when assigned package is deleted" do
        package.assign!

        expect { package.delete }
          .to change { dgfip.reload.packages_assigned_count }.from(1).to(0)
      end
    end

    describe "#packages_returned_count" do
      let(:collectivity) { create(:collectivity) }
      let(:package)      { create(:package, collectivity:) }

      it "doesn't change on package creation" do
        expect { package }
          .to not_change { dgfip.reload.packages_returned_count }.from(0)
      end

      it "changes when package is returned" do
        package

        expect { package.return! }
          .to change { dgfip.reload.packages_returned_count }.from(0).to(1)
      end

      it "changes when returned package is assigned" do
        package.return!

        expect { package.assign! }
          .to change { dgfip.reload.packages_returned_count }.from(1).to(0)
      end

      it "changes when returned package is discarded" do
        package.return!

        expect { package.discard }
          .to change { dgfip.reload.packages_returned_count }.from(1).to(0)
      end

      it "changes when returned package is undiscarded" do
        package.return!
        package.discard

        expect { package.undiscard }
          .to change { dgfip.reload.packages_returned_count }.from(0).to(1)
      end

      it "changes when returned package is deleted" do
        package.return!

        expect { package.delete }
          .to change { dgfip.reload.packages_returned_count }.from(1).to(0)
      end
    end
  end
end
