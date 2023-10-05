# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publisher do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:collectivities) }
    it { is_expected.to have_many(:transmissions) }
    it { is_expected.to have_many(:packages) }
    it { is_expected.to have_many(:reports) }
    it { is_expected.to have_many(:oauth_applications) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    subject { build(:publisher) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }

    it { is_expected.to     allow_value("801453893").for(:siren) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren) }
    it { is_expected.not_to allow_value("1234567891").for(:siren) }

    it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
    it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

    it "validates uniqueness of :siren & :name" do
      create(:publisher)

      aggregate_failures do
        is_expected.to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "ignores discarded records when validating uniqueness of :siren & :name" do
      create(:publisher, :discarded)

      aggregate_failures do
        is_expected.not_to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_publishers = create_list(:publisher, 2, :discarded)
      create(:publisher, siren: discarded_publishers[0].siren, name: discarded_publishers[1].name)

      aggregate_failures do
        expect { discarded_publishers[0].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
        expect { discarded_publishers[1].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR "publishers"."siren" = 'Hello')
        SQL
      end
    end

    describe ".order_by_param" do
      it do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          ORDER BY UNACCENT("publishers"."name") ASC, "publishers"."created_at" ASC
        SQL
      end

      it do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          ORDER BY UNACCENT("publishers"."name") DESC, "publishers"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          ORDER BY ts_rank_cd(to_tsvector('french', "publishers"."name"), to_tsquery('french', 'Hello')) DESC,
                  "publishers"."created_at" ASC
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:publishers) { create_list(:publisher, 2) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_publishers_counters()")
      end

      it "returns the number of concerned publishers" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: publishers[0])
          create_list(:user, 2, organization: publishers[1])
          create(:user, :discarded, organization: publishers[0])

          Publisher.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { publishers[0].reload.users_count }.to(4)
            .and change { publishers[1].reload.users_count }.to(2)
        end
      end

      describe "collectivities counts" do
        before_all do
          create_list(:collectivity, 2)
          create_list(:collectivity, 2, publisher: publishers[0])
          create_list(:collectivity, 4, publisher: publishers[1])
          create(:collectivity, :discarded, publisher: publishers[0])

          Publisher.update_all(collectivities_count: 99)
        end

        it "updates #collectivities_count" do
          expect {
            described_class.reset_all_counters
          }.to change { publishers[0].reload.collectivities_count }.to(2)
            .and change { publishers[1].reload.collectivities_count }.to(4)
        end
      end

      describe "reports & packages counts" do
        before_all do
          publishers[0].tap do |publisher|
            create(:collectivity, :with_users, publisher:, users_size: 1).tap do |collectivity|
              create_list(:report, 2, :completed, publisher:, collectivity:)

              create(:package, :with_reports, :transmitted_through_web_ui, collectivity:)
              create(:package, :with_reports, :transmitted_through_api,    collectivity:, publisher:)
              create(:package, :with_reports, :transmitted_through_api, :assigned, collectivity:, publisher:).tap do |package|
                create_list(:report, 2, :approved, publisher:, collectivity:, package:)
                create_list(:report, 3, :rejected, publisher:, collectivity:, package:)
              end
            end
          end

          publishers[1].tap do |publisher|
            create(:collectivity, publisher:).tap do |collectivity|
              create(:package, :with_reports, :transmitted_through_api, :returned, collectivity:, publisher:)
              create(:package, :with_reports, :transmitted_through_api, :assigned, collectivity:, publisher:).tap do |package|
                create_list(:report, 1, :debated, publisher:, collectivity:, package:)
              end
            end
          end

          Publisher.update_all(
            reports_transmitted_count:  99,
            reports_approved_count:     99,
            reports_rejected_count:     99,
            reports_debated_count:      99,
            packages_transmitted_count: 99,
            packages_assigned_count:    99,
            packages_returned_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_transmitted_count }.to(7)
            .and change { publishers[1].reload.reports_transmitted_count }.to(3)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_approved_count }.to(2)
            .and change { publishers[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_rejected_count }.to(3)
            .and change { publishers[1].reload.reports_rejected_count }.to(0)
        end

        it "updates #reports_debated_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_debated_count }.to(0)
            .and change { publishers[1].reload.reports_debated_count }.to(1)
        end

        it "updates #packages_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.packages_transmitted_count }.to(2)
            .and change { publishers[1].reload.packages_transmitted_count }.to(2)
        end

        it "updates #packages_assigned_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.packages_assigned_count }.to(1)
            .and change { publishers[1].reload.packages_assigned_count }.to(1)
        end

        it "updates #packages_returned_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.packages_returned_count }.to(0)
            .and change { publishers[1].reload.packages_returned_count }.to(1)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database triggers" do
    let!(:publisher) { create(:publisher) }

    describe "#users_count" do
      let(:user) { create(:user, organization: publisher) }

      it "changes on creation" do
        expect { user }
          .to change { publisher.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user

        expect { user.destroy }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user

        expect { user.discard }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user.discard

        expect { user.undiscard }
          .to change { publisher.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user
        another_publisher = create(:publisher)

        expect { user.update(organization: another_publisher) }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end
    end

    describe "#collectivities_count" do
      let(:collectivity) { create(:collectivity, publisher:) }

      it "changes on creation" do
        expect { collectivity }
          .to change { publisher.reload.collectivities_count }.from(0).to(1)
      end

      it "changes on deletion" do
        collectivity

        expect { collectivity.destroy }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        collectivity

        expect { collectivity.discard }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end

      it "changes when collectivity is undiscarded" do
        collectivity.discard

        expect { collectivity.undiscard }
          .to change { publisher.reload.collectivities_count }.from(0).to(1)
      end

      it "changes when collectivity switches to another publisher" do
        collectivity
        another_publisher = create(:publisher)

        expect { collectivity.update(publisher: another_publisher) }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, :transmitted_through_api, publisher:, collectivity:) }
      let(:report)       { create(:report, :made_through_api, publisher:, collectivity:) }

      it "doesn't change when report is created" do
        expect { report }
          .not_to change { publisher.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report

        expect { report.update(package:) }
          .to change { publisher.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report
        package.update(sandbox: true)

        expect { report.update(package:) }
          .not_to change { publisher.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is discarded" do
        report.update(package:)

        expect { report.discard }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when report is undiscarded" do
        report.update(package:)
        report.discard

        expect { report.undiscard }
          .to change { publisher.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when report is deleted" do
        report.update(package:)

        expect { report.destroy }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when package is discarded" do
        report.update(package:)

        expect { package.discard }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when package is undiscarded" do
        report.update(package:)
        package.discard

        expect { package.undiscard }
          .to change { publisher.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when package is deleted" do
        report.update(package:)

        expect { package.delete }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_debated_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, :transmitted_through_api, :assigned, publisher:, collectivity:) }
      let(:report)       { create(:report, :made_through_api, publisher:, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { publisher.reload.reports_debated_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { publisher.reload.reports_debated_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { publisher.reload.reports_debated_count }.from(0)
      end

      it "changes when report is debated" do
        report

        expect { report.debate! }
          .to change { publisher.reload.reports_debated_count }.from(0).to(1)
      end

      it "changes when debated report is reseted" do
        report.debate!

        expect { report.update(debated_at: nil) }
          .to change { publisher.reload.reports_debated_count }.from(1).to(0)
      end

      it "changes when debated report is approved" do
        report.debate!

        expect { report.approve! }
          .to change { publisher.reload.reports_debated_count }.from(1).to(0)
      end

      it "changes when debated report is rejected" do
        report.debate!

        expect { report.reject! }
          .to change { publisher.reload.reports_debated_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, :transmitted_through_api, :assigned, publisher:, collectivity:) }
      let(:report)       { create(:report, :made_through_api, publisher:, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is debated" do
        report

        expect { report.debate! }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report

        expect { report.approve! }
          .to change { publisher.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report.approve!

        expect { report.update(approved_at: nil) }
          .to change { publisher.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report.approve!

        expect { report.reject! }
          .to change { publisher.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, :transmitted_through_api, :assigned, publisher:, collectivity:) }
      let(:report)       { create(:report, :made_through_api, publisher:, collectivity:, package:) }

      it "doesn't change when package is assigned" do
        expect { report }
          .not_to change { publisher.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { publisher.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is debated" do
        report

        expect { report.debate! }
          .not_to change { publisher.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report

        expect { report.reject! }
          .to change { publisher.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report.reject!

        expect { report.update(rejected_at: nil) }
          .to change { publisher.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report.reject!

        expect { report.approve! }
          .to change { publisher.reload.reports_rejected_count }.from(1).to(0)
      end
    end

    describe "#packages_transmitted_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, publisher:, collectivity:) }

      it "changes on package creation" do
        expect { package }
          .to change { publisher.reload.packages_transmitted_count }.from(0).to(1)
      end

      it "doesn't changes when package is created in sandbox" do
        expect { create(:package, publisher:, sandbox: true) }
          .not_to change { publisher.reload.packages_transmitted_count }.from(0)
      end

      it "doesn't changes when package switches to sandbox" do
        package

        expect { package.update(sandbox: true) }
          .to change { publisher.reload.packages_transmitted_count }.from(1).to(0)
      end

      it "doesn't changes when package is assigned" do
        package

        expect { package.assign! }
          .not_to change { publisher.reload.packages_transmitted_count }.from(1)
      end

      it "doesn't changes when package is returned" do
        package

        expect { package.return! }
          .not_to change { publisher.reload.packages_transmitted_count }.from(1)
      end

      it "changes when package is discarded" do
        package

        expect { package.discard }
          .to change { publisher.reload.packages_transmitted_count }.from(1).to(0)
      end

      it "changes when package is undiscarded" do
        package.discard

        expect { package.undiscard }
          .to change { publisher.reload.packages_transmitted_count }.from(0).to(1)
      end

      it "changes when package is deleted" do
        package

        expect { package.delete }
          .to change { publisher.reload.packages_transmitted_count }.from(1).to(0)
      end
    end

    describe "#packages_assigned_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, publisher:, collectivity:) }

      it "doesn't changes on package creation" do
        expect { package }
          .to not_change { publisher.reload.packages_assigned_count }.from(0)
      end

      it "changes when package is assigned" do
        package

        expect { package.assign! }
          .to change { publisher.reload.packages_assigned_count }.from(0).to(1)
      end

      it "changes when assigned package is then returned" do
        package.assign!

        expect { package.return! }
          .to change { publisher.reload.packages_assigned_count }.from(1).to(0)
      end

      it "changes when assigned package is discarded" do
        package.assign!

        expect { package.discard }
          .to change { publisher.reload.packages_assigned_count }.from(1).to(0)
      end

      it "changes when assigned package is undiscarded" do
        package.assign!
        package.discard

        expect { package.undiscard }
          .to change { publisher.reload.packages_assigned_count }.from(0).to(1)
      end

      it "changes when assigned package is deleted" do
        package.assign!

        expect { package.delete }
          .to change { publisher.reload.packages_assigned_count }.from(1).to(0)
      end
    end

    describe "#packages_returned_count" do
      let(:collectivity) { create(:collectivity, publisher:) }
      let(:package)      { create(:package, publisher:, collectivity:) }

      it "doesn't change on package creation" do
        expect { package }
          .to not_change { publisher.reload.packages_returned_count }.from(0)
      end

      it "changes when package is returned" do
        package

        expect { package.return! }
          .to change { publisher.reload.packages_returned_count }.from(0).to(1)
      end

      it "changes when returned package is assigned" do
        package.return!

        expect { package.assign! }
          .to change { publisher.reload.packages_returned_count }.from(1).to(0)
      end

      it "changes when returned package is discarded" do
        package.return!

        expect { package.discard }
          .to change { publisher.reload.packages_returned_count }.from(1).to(0)
      end

      it "changes when returned package is undiscarded" do
        package.return!
        package.discard

        expect { package.undiscard }
          .to change { publisher.reload.packages_returned_count }.from(0).to(1)
      end

      it "changes when returned package is deleted" do
        package.return!

        expect { package.delete }
          .to change { publisher.reload.packages_returned_count }.from(1).to(0)
      end
    end
  end
end
