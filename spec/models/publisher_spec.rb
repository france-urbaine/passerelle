# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publisher do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:collectivities) }
    it { is_expected.to have_many(:packages) }
    it { is_expected.to have_many(:reports) }
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

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }

    context "when existing publisher is discarded" do
      subject { build(:publisher, :discarded) }

      it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.not_to validate_uniqueness_of(:siren).case_insensitive }
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
          create_list(:package, 2, :transmitted, publisher: publishers[0])

          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_transmitted_count }.from(0) }
      end

      describe "on packages_approved_count" do
        before do
          create_list(:package, 2, :approved, publisher: publishers[0])

          Publisher.update_all(packages_approved_count: 0)
          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_approved_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_approved_count }.from(0) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_transmitted_count }.from(0) }
      end

      describe "on packages_rejected_count" do
        before do
          create_list(:package, 2, :rejected, publisher: publishers[0])

          Publisher.update_all(packages_rejected_count: 0)
          Publisher.update_all(packages_transmitted_count: 0)
        end

        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_rejected_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to change { publishers[0].reload.packages_transmitted_count }.from(0).to(2) }
        it { expect { reset_all_counters }.to not_change { publishers[1].reload.packages_rejected_count }.from(0) }
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
            .to      change { publishers[0].reload.users_count }.from(0).to(1)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes on deletion" do
          user
          expect { user.destroy }
            .to      change { publishers[0].reload.users_count }.from(1).to(0)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes when discarding" do
          user
          expect { user.discard }
            .to      change { publishers[0].reload.users_count }.from(1).to(0)
            .and not_change { publishers[1].reload.users_count }.from(0)
        end

        it "changes when undiscarding" do
          user.discard
          expect { user.undiscard }
            .to      change { publishers[0].reload.users_count }.from(0).to(1)
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
            .to      change { publishers[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on discarding" do
          collectivity
          expect { collectivity.discard }
            .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on undiscarding" do
          collectivity.discard
          expect { collectivity.undiscard }
            .to      change { publishers[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes on deletion" do
          collectivity
          expect { collectivity.destroy }
            .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
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
            .to      change { publishers[0].reload.collectivities_count }.from(1).to(0)
            .and not_change { publishers[1].reload.collectivities_count }.from(0)
        end

        it "changes when combining updating publisher and undiscarding" do
          collectivity.discard
          expect { collectivity.update(publisher: publishers[1], discarded_at: nil) }
            .to  not_change { publishers[0].reload.collectivities_count }.from(0)
            .and     change { publishers[1].reload.collectivities_count }.from(0).to(1)
        end
      end
    end

    describe "about reports counter caches" do
      describe "#reports_transmitted_count" do
        let(:package) { create(:package, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when package is transmitted" do
          report

          expect { report.package.transmit! }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          report.package.update(sandbox: true)

          expect { report.package.transmit! }
            .to  not_change { publishers[0].reload.reports_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is discarded" do
          report.package.touch(:transmitted_at)

          expect { report.discard }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is undiscarded" do
          report.discard and package.transmit!

          expect { report.undiscard }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted report is deleted" do
          report.package.transmit!

          expect { report.destroy }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is discarded" do
          report.package.transmit!

          expect { package.discard }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is undiscarded" do
          report.package.touch(:transmitted_at, :discarded_at)

          expect { package.undiscard }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end

        it "changes when transmitted package is deleted" do
          report.package.transmit!

          expect { package.delete }
            .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
        end
      end

      describe "#reports_approved_count" do
        let(:package) { create(:package, :transmitted, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_approved_count }.from(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when report is approved" do
          report

          expect { report.approve! }
            .to      change { publishers[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is discarded" do
          report.approve!

          expect { report.discard }
            .to      change { publishers[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is undiscarded" do
          report.touch(:approved_at, :discarded_at)

          expect { report.undiscard }
            .to      change { publishers[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved report is deleted" do
          report.touch(:approved_at)

          expect { report.delete }
            .to      change { publishers[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_approved_count }.from(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:package) { create(:package, :transmitted, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_rejected_count }.from(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when report is rejected" do
          report

          expect { report.reject! }
            .to      change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is discarded" do
          report.reject!

          expect { report.discard }
            .to      change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is undiscarded" do
          report.touch(:rejected_at, :discarded_at)

          expect { report.undiscard }
            .to      change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected report is deleted" do
          report.touch(:rejected_at)

          expect { report.delete }
            .to      change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
        end
      end

      describe "#reports_debated_count" do
        let(:package) { create(:package, :transmitted, publisher: publishers[0]) }
        let(:report)  { create(:report, package: package, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { publishers[0].reload.reports_debated_count }.from(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when report is marked as debated" do
          report

          expect { report.debate! }
            .to      change { publishers[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is discarded" do
          report.debate!

          expect { report.discard }
            .to      change { publishers[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is undiscarded" do
          report.touch(:debated_at, :discarded_at)

          expect { report.undiscard }
            .to      change { publishers[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated report is deleted" do
          report.touch(:debated_at)

          expect { report.delete }
            .to      change { publishers[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { publishers[1].reload.reports_debated_count }.from(0)
        end
      end
    end

    describe "about packages counter caches" do
      describe "#packages_transmitted_count" do
        let(:package) { create(:package, publisher: publishers[0]) }

        it "doesn't change on package creation" do
          expect { package }
            .to  not_change { publishers[0].reload.packages_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when package is transmitted" do
          package
          expect { package.transmit! }
            .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          package.update(sandbox: true)

          expect { package.transmit! }
            .to  not_change { publishers[0].reload.packages_transmitted_count }.from(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is discarded" do
          package.transmit!
          expect { package.discard }
            .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is undiscarded" do
          package.touch(:transmitted_at, :discarded_at)
          expect { package.undiscard }
            .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end

        it "changes when transmitted package is deleted" do
          package.transmit!
          expect { package.delete }
            .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
        end
      end

      describe "#packages_approved_count" do
        let(:package) { create(:package, :transmitted, publisher: publishers[0]) }

        it "doesn't change on package creation" do
          expect { package }
            .to  not_change { publishers[0].reload.packages_approved_count }.from(0)
            .and not_change { publishers[1].reload.packages_approved_count }.from(0)
        end

        it "changes when package is approved" do
          package
          expect { package.approve! }
            .to      change { publishers[0].reload.packages_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_approved_count }.from(0)
        end

        it "changes when approved package is discarded" do
          package.approve!
          expect { package.discard }
            .to      change { publishers[0].reload.packages_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_approved_count }.from(0)
        end

        it "changes when approved package is undiscarded" do
          package.touch(:approved_at, :discarded_at)
          expect { package.undiscard }
            .to      change { publishers[0].reload.packages_approved_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_approved_count }.from(0)
        end

        it "changes when approved package is deleted" do
          package.approve!
          expect { package.delete }
            .to      change { publishers[0].reload.packages_approved_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_approved_count }.from(0)
        end
      end

      describe "#packages_rejected_count" do
        let(:package) { create(:package, :transmitted, publisher: publishers[0]) }

        it "doesn't change on report creation" do
          expect { package }
            .to  not_change { publishers[0].reload.packages_rejected_count }.from(0)
            .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
        end

        it "changes when package is rejected" do
          package
          expect { package.reject! }
            .to      change { publishers[0].reload.packages_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
        end

        it "changes when rejected package is discarded" do
          package.reject!
          expect { package.discard }
            .to      change { publishers[0].reload.packages_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
        end

        it "changes when rejected package is undiscarded" do
          package.touch(:rejected_at, :discarded_at)
          expect { package.undiscard }
            .to      change { publishers[0].reload.packages_rejected_count }.from(0).to(1)
            .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
        end

        it "changes when rejected package is deleted" do
          package.reject!
          expect { package.delete }
            .to      change { publishers[0].reload.packages_rejected_count }.from(1).to(0)
            .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
        end
      end
    end
  end
end
