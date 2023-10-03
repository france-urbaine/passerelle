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
      subject(:reset_all_counters) { described_class.reset_all_counters }

      let!(:publishers) { create_list(:publisher, 2) }

      it { expect { reset_all_counters }.to ret(2) }
      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_publishers_counters()") }

      describe "on users_count" do
        before do
          create_list(:user, 4, organization: publishers[0])
          create_list(:user, 2, organization: publishers[1])
          create_list(:user, 1, :publisher)
          create_list(:user, 1, :collectivity)

          Publisher.update_all(users_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.users_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { publishers[1].reload.users_count }.from(0).to(2) }
      end

      describe "on collectivities_count" do
        before do
          create_list(:collectivity, 3, publisher: publishers[0])
          create_list(:collectivity, 2, publisher: publishers[1])
          create_list(:collectivity, 2, :discarded, publisher: publishers[1])

          Publisher.update_all(collectivities_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.collectivities_count }.from(0).to(3) }
        it { expect { reset_all_counters }.to change { publishers[1].reload.collectivities_count }.from(0).to(2) }
      end

      describe "on reports_transmitted_count" do
        before do
          create_list(:report, 2, :transmitted, publisher: publishers[0])

          Publisher.update_all(reports_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_transmitted_count }.from(0) }
      end

      describe "on reports_approved_count" do
        before do
          create_list(:report, 2, :approved, publisher: publishers[0])

          Publisher.update_all(reports_approved_count: 0)
          Publisher.update_all(reports_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_approved_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_approved_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_transmitted_count }.from(0) }
      end

      describe "on reports_rejected_count" do
        before do
          create_list(:report, 2, :rejected, publisher: publishers[0])

          Publisher.update_all(reports_rejected_count: 0)
          Publisher.update_all(reports_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_rejected_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_rejected_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_transmitted_count }.from(0) }
      end

      describe "on reports_debated_count" do
        before do
          create_list(:report, 2, :debated, publisher: publishers[0])

          Publisher.update_all(reports_debated_count: 0)
          Publisher.update_all(reports_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_debated_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.reports_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_debated_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.reports_transmitted_count }.from(0) }
      end

      describe "on packages_transmitted_count" do
        before do
          create_list(:package, 2, publisher: publishers[0])

          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_transmitted_count }.from(0) }
      end

      describe "on packages_assigned_count" do
        before do
          create_list(:package, 2, :assigned, publisher: publishers[0])

          Publisher.update_all(packages_assigned_count: 0)
          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_assigned_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_assigned_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_transmitted_count }.from(0) }
      end

      describe "on packages_returned_count" do
        before do
          create_list(:package, 2, :returned, publisher: publishers[0])

          Publisher.update_all(packages_returned_count: 0)
          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_returned_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_returned_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_transmitted_count }.from(0) }
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database triggers" do
    let!(:publishers) { create_list(:publisher, 2) }

    describe "about organization counter caches" do
      describe "#users_count" do
        let(:user) { create(:user, organization: publishers[0]) }

        it "changes on creation" do
          expect { user }
            .to change { publishers[0].reload.users_count }.from(0).to(1)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes on deletion" do
          user
          expect { user.destroy }
            .to change { publishers[0].reload.users_count }.from(1).to(0)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes when discarding" do
          user
          expect { user.discard }
            .to change { publishers[0].reload.users_count }.from(1).to(0)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes when undiscarding" do
          user.discard
          expect { user.undiscard }
            .to change { publishers[0].reload.users_count }.from(0).to(1)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes when updating organization" do
          user
          expect { user.update(organization: publishers[1]) }
            .to  change { publishers[0].reload.users_count }.from(1).to(0)
            .and change { publishers[1].reload.users_count }.from(0).to(1)
        end
      end

      describe "#collectivities_count" do
        let(:collectivity) { create(:collectivity, publisher: publishers[0]) }

        it "changes on creation" do
          expect { collectivity }
            .to change { publishers[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on discarding" do
          collectivity
          expect { collectivity.discard }
            .to change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on undiscarding" do
          collectivity.discard
          expect { collectivity.undiscard }
            .to change { publishers[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on deletion" do
          collectivity
          expect { collectivity.destroy }
            .to change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "doesn't change when deleting a discarded collectivity" do
          collectivity.discard
          expect { collectivity.destroy }
            .to  not_change { publishers[0].reload.collectivities_count }.from(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes when updating publisher" do
          collectivity
          expect { collectivity.update(publisher: publishers[1]) }
            .to  change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and change { publishers[1].reload.collectivities_count }.from(0).to(1)
        end

        it "doesn't change when updating publisher of a discarded collectivity" do
          collectivity.discard
          expect { collectivity.update(publisher: publishers[1]) }
            .to  not_change { publishers[0].reload.collectivities_count }.from(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes when combining updating publisher and discarding" do
          collectivity
          expect { collectivity.update(publisher: publishers[1], discarded_at: Time.current) }
            .to change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes when combining updating publisher and undiscarding" do
          collectivity.discard
          expect { collectivity.update(publisher: publishers[1], discarded_at: nil) }
            .to  not_change { publishers[0].reload.collectivities_count }.from(0)
            .and change { publishers[1].reload.collectivities_count }.from(0).to(1)
        end
      end
    end

    describe "about reports counter caches" do
      describe "#reports_transmitted_count" do
        let(:package) { create(:package, publisher: publishers[0]) }
        let(:report)  { create(:report, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when package is transmitted" do
          report

          expect { report.update(package: package) }
            .to change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          package.update(sandbox: true)

          expect { report.update(package: package) }
            .to  not_change { publishers[0].reload.reports_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is discarded" do
          report.update(package: package)

          expect { report.discard }
            .to change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is undiscarded" do
          report.update(package: package)
          report.discard

          expect { report.undiscard }
            .to change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is deleted" do
          report.update(package: package)

          expect { report.destroy }
            .to change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is discarded" do
          report.update(package: package)

          expect { package.discard }
            .to change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is undiscarded" do
          report.update(package: package)
          package.discard

          expect { package.undiscard }
            .to change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is deleted" do
          report.update(package: package)

          expect { package.delete }
            .to change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end
      end

      describe "#reports_approved_count" do
        let(:package) { create(:package, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_approved_count }.from(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when report is approved" do
          report

          expect { report.approve! }
            .to change { publishers[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is discarded" do
          report.approve!

          expect { report.discard }
            .to change { publishers[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is undiscarded" do
          report.touch(:approved_at, :discarded_at)

          expect { report.undiscard }
            .to change { publishers[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is deleted" do
          report.touch(:approved_at)

          expect { report.delete }
            .to change { publishers[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:package) { create(:package, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_rejected_count }.from(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when report is rejected" do
          report

          expect { report.reject! }
            .to change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is discarded" do
          report.reject!

          expect { report.discard }
            .to change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is undiscarded" do
          report.touch(:rejected_at, :discarded_at)

          expect { report.undiscard }
            .to change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is deleted" do
          report.touch(:rejected_at)

          expect { report.delete }
            .to change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end
      end

      describe "#reports_debated_count" do
        let(:package) { create(:package, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_debated_count }.from(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when report is marked as debated" do
          report

          expect { report.debate! }
            .to change { publishers[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is discarded" do
          report.debate!

          expect { report.discard }
            .to change { publishers[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is undiscarded" do
          report.touch(:debated_at, :discarded_at)

          expect { report.undiscard }
            .to change { publishers[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is deleted" do
          report.touch(:debated_at)

          expect { report.delete }
            .to change { publishers[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end
      end
    end

    describe "about packages counter caches" do
      describe "#packages_transmitted_count" do
        let(:package) { create(:package, publisher: publishers[0]) }

        it "changes on package creation" do
          expect { package }
            .to change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          expect { create(:package, publisher: publishers[0], sandbox: true) }
            .to  not_change { publishers[0].reload.packages_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is discarded" do
          package

          expect { package.discard }
            .to change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is undiscarded" do
          package.discard

          expect { package.undiscard }
            .to change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is deleted" do
          package

          expect { package.delete }
            .to change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end
      end

      describe "#packages_assigned_count" do
        let(:package) { create(:package, publisher: publishers[0]) }

        it "doesn't change on package creation" do
          expect { package }
            .to  not_change { publishers[0].reload.packages_assigned_count }.from(0)
            .and not_change { publishers[1].reload.packages_assigned_count }.from(0)
        end

        it "changes when package is assigned" do
          package
          expect { package.assign! }
            .to change { publishers[0].reload.packages_assigned_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_assigned_count }.from(0)
        end

        it "changes when assigned package is discarded" do
          package.assign!
          expect { package.discard }
            .to change { publishers[0].reload.packages_assigned_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_assigned_count }.from(0)
        end

        it "changes when assigned package is undiscarded" do
          package.touch(:assigned_at, :discarded_at)
          expect { package.undiscard }
            .to change { publishers[0].reload.packages_assigned_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_assigned_count }.from(0)
        end

        it "changes when assigned package is deleted" do
          package.assign!
          expect { package.delete }
            .to change { publishers[0].reload.packages_assigned_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_assigned_count }.from(0)
        end
      end

      describe "#packages_returned_count" do
        let(:package) { create(:package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { package }
            .to  not_change { publishers[0].reload.packages_returned_count }.from(0)
            .and not_change { publishers[1].reload.packages_returned_count }.from(0)
        end

        it "changes when package is returned" do
          package
          expect { package.return! }
            .to change { publishers[0].reload.packages_returned_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_returned_count }.from(0)
        end

        it "changes when returned package is discarded" do
          package.return!
          expect { package.discard }
            .to change { publishers[0].reload.packages_returned_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_returned_count }.from(0)
        end

        it "changes when returned package is undiscarded" do
          package.touch(:returned_at, :discarded_at)
          expect { package.undiscard }
            .to change { publishers[0].reload.packages_returned_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_returned_count }.from(0)
        end

        it "changes when returned package is deleted" do
          package.return!
          expect { package.delete }
            .to change { publishers[0].reload.packages_returned_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_returned_count }.from(0)
        end
      end
    end
  end
end
