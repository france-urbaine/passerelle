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
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }

    it { is_expected.to     allow_value("801453893").for(:siren) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren) }
    it { is_expected.not_to allow_value("1234567891").for(:siren) }

    it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
    it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

    context "with an existing publisher" do
      # FYI: About uniqueness validations, case insensitivity and accents:
      # You should read ./docs/uniqueness_validations_and_accents.md
      before { create(:publisher) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }
    end

    context "when existing publisher is discarded" do
      before { create(:publisher, :discarded) }

      it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.not_to validate_uniqueness_of(:siren).case_insensitive }
    end
  end

  # Search
  # ----------------------------------------------------------------------------
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

  # Order scope
  # ----------------------------------------------------------------------------
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

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:publishers) { create_list(:publisher, 2) }
    let(:report) { create(:report, publisher: publishers[0]) }
    let(:transmitted_report) { create(:report, :transmitted, publisher: publishers[0]) }
    let(:package) { create(:package, publisher: publishers[0]) }
    let(:transmitted_package) { create(:package, :transmitted, publisher: publishers[0]) }

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

    describe "#report_transmitted_count" do
      it "changes on report's creation" do
        expect { transmitted_report }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end

      it "changes on report's deletion" do
        transmitted_report
        expect { transmitted_report.destroy }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is discarded" do
        transmitted_report
        expect { transmitted_report.discard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is undiscarded" do
        transmitted_report.discard
        expect { transmitted_report.undiscard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        transmitted_report
        expect { transmitted_report.package.update(sandbox: true) }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end

      it "changes when package is transmitted" do
        report
        expect { report.package.transmit! }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
      end
    end

    describe "#reports_approved_count" do
      let(:approved_report) { create(:report, :approved, publisher: publishers[0]) }

      it "changes on report's creation" do
        expect { approved_report }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "changes on report's deletion" do
        approved_report
        expect { approved_report.destroy }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report is discarded" do
        approved_report
        expect { approved_report.discard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report is undiscarded" do
        approved_report.discard
        expect { approved_report.undiscard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report is a approved" do
        transmitted_report
        expect { transmitted_report.update(approved_at: Time.current) }
          .to  not_change { publishers[0].reload.reports_transmitted_count }.from(1)
          .and     change { publishers[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        approved_report
        expect { approved_report.package.update(sandbox: true) }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        report
        expect { report.package.transmit! }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[0].reload.reports_approved_count }.from(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_approved_count }.from(0)
      end
    end

    describe "#reports_rejected_count" do
      let(:rejected_report) { create(:report, :rejected, publisher: publishers[0]) }

      it "changes on report's creation" do
        expect { rejected_report }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "changes on report's deletion" do
        rejected_report
        expect { rejected_report.destroy }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report is discarded" do
        rejected_report
        expect { rejected_report.discard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report is undiscarded" do
        rejected_report.discard
        expect { rejected_report.undiscard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report is a rejected" do
        transmitted_report
        expect { transmitted_report.update(rejected_at: Time.current) }
          .to  not_change { publishers[0].reload.reports_transmitted_count }.from(1)
          .and     change { publishers[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        rejected_report
        expect { rejected_report.package.update(sandbox: true) }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        report
        expect { report.package.transmit! }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[0].reload.reports_rejected_count }.from(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end
    end

    describe "#reports_debated_count" do
      let(:debated_report) { create(:report, :debated, publisher: publishers[0]) }

      it "changes on report's creation" do
        expect { debated_report }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "changes on report's deletion" do
        debated_report
        expect { debated_report.destroy }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report is discarded" do
        debated_report
        expect { debated_report.discard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report is undiscarded" do
        debated_report.discard
        expect { debated_report.undiscard }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report is a debated" do
        transmitted_report
        expect { transmitted_report.update(debated_at: Time.current) }
          .to  not_change { publishers[0].reload.reports_transmitted_count }.from(1)
          .and     change { publishers[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        debated_report
        expect { debated_report.package.update(sandbox: true) }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_debated_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        report
        expect { report.package.transmit! }
          .to      change { publishers[0].reload.reports_transmitted_count }.from(0).to(1)
          .and not_change { publishers[0].reload.reports_rejected_count }.from(0)
          .and not_change { publishers[1].reload.reports_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.reports_rejected_count }.from(0)
      end
    end

    describe "#package_transmitted_count" do
      it "changes on package's creation" do
        expect { transmitted_package }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end

      it "changes on package's deletion" do
        transmitted_package
        expect { transmitted_package.destroy }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end

      it "changes when package is discarded" do
        transmitted_package
        expect { transmitted_package.discard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end

      it "changes when package is undiscarded" do
        transmitted_package.discard
        expect { transmitted_package.undiscard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end

      it "changes when package is a sandbox" do
        transmitted_package
        expect { transmitted_package.update(sandbox: true) }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end

      it "changes when package is transmitted" do
        package
        expect { package.transmit! }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
      end
    end

    describe "#packages_approved_count" do
      let(:approved_package) { create(:package, :approved, publisher: publishers[0]) }

      it "changes on package's creation" do
        expect { approved_package }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.packages_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "changes on package's deletion" do
        approved_package
        expect { approved_package.destroy }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "changes when package is discarded" do
        approved_package
        expect { approved_package.discard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "changes when package is undiscarded" do
        approved_package.discard
        expect { approved_package.undiscard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.packages_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "changes when package is a sandbox" do
        approved_package
        expect { approved_package.update(sandbox: true) }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_approved_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "changes when package is approved" do
        transmitted_package
        expect { transmitted_package.approve! }
          .to  not_change { publishers[0].reload.packages_transmitted_count }.from(1)
          .and     change { publishers[0].reload.packages_approved_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        package
        expect { package.transmit! }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and not_change { publishers[0].reload.packages_approved_count }.from(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_approved_count }.from(0)
      end
    end

    describe "#packages_rejected_count" do
      let(:rejected_package) { create(:package, :rejected, publisher: publishers[0]) }

      it "changes on package's creation" do
        expect { rejected_package }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.packages_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "changes on package's deletion" do
        rejected_package
        expect { rejected_package.destroy }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "changes when package is discarded" do
        rejected_package
        expect { rejected_package.discard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "changes when package is undiscarded" do
        rejected_package.discard
        expect { rejected_package.undiscard }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and     change { publishers[0].reload.packages_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "changes when package is a sandbox" do
        rejected_package
        expect { rejected_package.update(sandbox: true) }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(1).to(0)
          .and     change { publishers[0].reload.packages_rejected_count }.from(1).to(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "changes when package is rejected" do
        transmitted_package
        expect { transmitted_package.reject! }
          .to  not_change { publishers[0].reload.packages_transmitted_count }.from(1)
          .and     change { publishers[0].reload.packages_rejected_count }.from(0).to(1)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        package
        expect { package.transmit! }
          .to      change { publishers[0].reload.packages_transmitted_count }.from(0).to(1)
          .and not_change { publishers[0].reload.packages_rejected_count }.from(0)
          .and not_change { publishers[1].reload.packages_transmitted_count }.from(0)
          .and not_change { publishers[1].reload.packages_rejected_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
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
