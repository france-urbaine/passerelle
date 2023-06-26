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
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:action).in_array(Office::ACTIONS) }
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:offices) { create_list(:office, 2) }

    describe "#users_count" do
      let(:user) { create(:user) }

      it "changes when users is assigned to the office" do
        expect { offices[0].users << user }
          .to      change { offices[0].reload.users_count }.from(0).to(1)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when users is removed from the office" do
        offices[0].users << user

        expect { offices[0].users.delete(user) }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when users is destroyed" do
        offices[0].users << user

        expect { user.destroy }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when discarding" do
        offices[0].users << user
        expect { user.discard }
          .to      change { offices[0].reload.users_count }.from(1).to(0)
          .and not_change { offices[1].reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        offices[0].users << user

        expect { user.undiscard }
          .to      change { offices[0].reload.users_count }.from(0).to(1)
          .and not_change { offices[1].reload.users_count }.from(0)
      end
    end

    describe "#communes_count" do
      let!(:commune) { create(:commune, code_insee: "64102") }

      it "changes when communes is assigned to the office" do
        expect { offices[0].communes << commune }
          .to      change { offices[0].reload.communes_count }.from(0).to(1)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when an existing code_insee is assigned to the office" do
        expect { offices[0].office_communes.create(code_insee: "64102") }
          .to      change { offices[0].reload.communes_count }.from(0).to(1)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "doesn't change when an unknown code_insee is assigned to the office" do
        expect { offices[0].office_communes.create(code_insee: "64024") }
          .to  not_change { offices[0].reload.communes_count }.from(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune is removed from the office" do
        offices[0].communes << commune

        expect { offices[0].communes.delete(commune) }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune is destroyed" do
        offices[0].communes << commune

        expect { commune.destroy }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end

      it "changes when commune updates its code_insee" do
        offices[0].communes << commune

        expect { commune.update(code_insee: "64024") }
          .to      change { offices[0].reload.communes_count }.from(1).to(0)
          .and not_change { offices[1].reload.communes_count }.from(0)
      end
    end

    describe "#reports_count" do
      before do
        commune = create(:commune)
        offices.first.communes << commune
        offices.first.update(action: Office::ACTIONS.first)
      end

      let(:commune) { Commune.first }
      let(:report) { create(:report, :package_approved_by_ddfip, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "changes on report's creation" do
        expect { report }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes on report's deletion" do
        report
        expect { report.destroy }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when report is discarded" do
        report
        expect { report.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when report is undiscarded" do
        report.discard
        expect { report.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        report
        expect { report.package.update(sandbox: true) }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end
    end

    describe "#reports_approved_count" do
      before do
        commune = create(:commune)
        offices.first.communes << commune
        offices.first.update(action: Office::ACTIONS.first)
      end

      let(:commune) { Commune.first }
      let(:approved_report) { create(:report, :package_approved_by_ddfip, :approved, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "changes on report's creation" do
        expect { approved_report }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes on report's deletion" do
        approved_report
        expect { approved_report.destroy }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report is discarded" do
        approved_report
        expect { approved_report.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report is undiscarded" do
        approved_report.discard
        expect { approved_report.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        approved_report
        expect { approved_report.package.update(sandbox: true) }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end
    end

    describe "#reports_rejected_count" do
      before do
        commune = create(:commune)
        offices.first.communes << commune
        offices.first.update(action: Office::ACTIONS.first)
      end

      let(:commune) { Commune.first }
      let(:rejected_report) { create(:report, :package_approved_by_ddfip, :rejected, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "changes on report's creation" do
        expect { rejected_report }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes on report's deletion" do
        rejected_report
        expect { rejected_report.destroy }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report is discarded" do
        rejected_report
        expect { rejected_report.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report is undiscarded" do
        rejected_report.discard
        expect { rejected_report.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        rejected_report
        expect { rejected_report.package.update(sandbox: true) }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end
    end

    describe "#reports_debated_count" do
      before do
        commune = create(:commune)
        offices.first.communes << commune
        offices.first.update(action: Office::ACTIONS.first)
      end

      let(:commune) { Commune.first }
      let(:debated_report) { create(:report, :package_approved_by_ddfip, :debated, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "changes on report's creation" do
        expect { debated_report }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes on report's deletion" do
        debated_report
        expect { debated_report.destroy }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report is discarded" do
        debated_report
        expect { debated_report.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report is undiscarded" do
        debated_report.discard
        expect { debated_report.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and     change { offices[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when report's package is a sandbox" do
        debated_report
        expect { debated_report.package.update(sandbox: true) }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and     change { offices[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    let!(:offices) { create_list(:office, 2) }

    it { expect { reset_all_counters }.to ret(2) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_offices_counters()") }

    describe "on users_count" do
      before do
        users = create_list(:user, 6)

        offices[0].users = users.shuffle.take(4)
        offices[1].users = users.shuffle.take(2)

        Office.update_all(users_count: 0)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.users_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.users_count }.from(0).to(2) }
    end

    describe "on communes_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Office.update_all(communes_count: 0)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.communes_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.communes_count }.from(0).to(2) }
    end

    describe "on reports_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Commune.all.each { |commune| create(:report, :package_approved_by_ddfip, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

        Office.update_all(reports_count: 0, action: Office::ACTIONS.first)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.reports_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.reports_count }.from(0).to(2) }
    end

    describe "on reports_approved_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Commune.all.each { |commune| create(:report, :package_approved_by_ddfip, :approved, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

        Office.update_all(reports_approved_count: 0, action: Office::ACTIONS.first)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.reports_approved_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.reports_approved_count }.from(0).to(2) }
    end

    describe "on reports_rejected_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Commune.all.each { |commune| create(:report, :package_approved_by_ddfip, :rejected, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

        Office.update_all(reports_rejected_count: 0, action: Office::ACTIONS.first)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.reports_rejected_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.reports_rejected_count }.from(0).to(2) }
    end

    describe "on reports_debated_count" do
      before do
        communes = create_list(:commune, 6)

        offices[0].communes = communes.shuffle.take(4)
        offices[1].communes = communes.shuffle.take(2)

        Commune.all.each { |commune| create(:report, :package_approved_by_ddfip, :debated, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

        Office.update_all(reports_debated_count: 0, action: Office::ACTIONS.first)
      end

      it { expect { reset_all_counters }.to change { offices[0].reload.reports_debated_count }.from(0).to(4) }
      it { expect { reset_all_counters }.to change { offices[1].reload.reports_debated_count }.from(0).to(2) }
    end
  end
end
