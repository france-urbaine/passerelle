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
      let(:report) { create(:report, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "doesn't change on report creation" do
        expect { report }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't change when package is transmitted" do
        report

        expect { report.package.transmit! }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted package is approved" do
        report.package.transmit!

        expect { report.package.approve! }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't changes when package in sandbox is transmitted" do
        report.package.update(sandbox: true)

        expect { report.package.transmit! }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't changes when transmitted package in sandbox is approved" do
        report.package.update(sandbox: true) and report.package.transmit!

        expect { report.package.approve! }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted report in approved package is discarded" do
        report.package.touch(:transmitted_at) and report.package.approve!

        expect { report.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted report in approved package is undiscarded" do
        report.discard and report.package.transmit! and report.package.approve!

        expect { report.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted report in approved package is deleted" do
        report.package.transmit! and report.package.approve!

        expect { report.destroy }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't change when transmitted package is discarded" do
        report.package.transmit!

        expect { report.package.discard }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted and approved package is discarded" do
        report.package.transmit! and report.package.approve!

        expect { report.package.discard }
          .to      change { offices[0].reload.reports_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't change when transmitted package is undiscarded" do
        report.package.touch(:transmitted_at, :discarded_at)

        expect { report.package.undiscard }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted and approved package is undiscarded" do
        report.package.touch(:transmitted_at, :discarded_at, :approved_at)

        expect { report.package.undiscard }
          .to      change { offices[0].reload.reports_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "doesn't change when transmitted package is deleted" do
        report.package.transmit!

        expect { report.package.delete }
          .to  not_change { offices[0].reload.reports_count }.from(0)
          .and not_change { offices[1].reload.reports_count }.from(0)
      end

      it "changes when transmitted and approved package is deleted" do
        report.package.transmit! and report.package.approve!

        expect { report.package.delete }
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
      let(:report) { create(:report, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "doesn't change on report creation" do
        expect { report }
          .to  not_change { offices[0].reload.reports_approved_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "doesn't change when transmitted report is approved" do
        report.package.touch(:transmitted_at)

        expect { report.approve! }
          .to  not_change { offices[0].reload.reports_approved_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when transmitted report in approved package is approved" do
        report.package.touch(:transmitted_at, :approved_at)

        expect { report.approve! }
          .to      change { offices[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "doesn't change when approved and transmitted report is discarded" do
        report.approve! and report.package.touch(:transmitted_at)

        expect { report.discard }
          .to  not_change { offices[0].reload.reports_approved_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when approved and transmitted report in approved package is discarded" do
        report.approve! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.discard }
          .to      change { offices[0].reload.reports_approved_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "doesn't change when approved and transmitted report is undiscarded" do
        report.touch(:approved_at, :discarded_at) and report.package.touch(:transmitted_at)

        expect { report.undiscard }
          .to  not_change { offices[0].reload.reports_approved_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when approved and transmitted report in approved package is undiscarded" do
        report.touch(:approved_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

        expect { report.undiscard }
          .to      change { offices[0].reload.reports_approved_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "doesn't change when approved and transmitted report is deleted" do
        report.approve! and report.package.touch(:transmitted_at)

        expect { report.delete }
          .to  not_change { offices[0].reload.reports_approved_count }.from(0)
          .and not_change { offices[1].reload.reports_approved_count }.from(0)
      end

      it "changes when approved and transmitted report in approved package is deleted" do
        report.approve! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.delete }
          .to      change { offices[0].reload.reports_approved_count }.from(1).to(0)
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
      let(:report) { create(:report, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "doesn't change on report creation" do
        expect { report }
          .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "doesn't change when transmitted report is rejected" do
        report.package.touch(:transmitted_at)

        expect { report.reject! }
          .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when transmitted report in approved package is rejected" do
        report.package.touch(:transmitted_at, :approved_at)

        expect { report.reject! }
          .to      change { offices[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "doesn't change when rejected and transmitted report is discarded" do
        report.reject! and report.package.touch(:transmitted_at)

        expect { report.discard }
          .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected and transmitted report in approved package is discarded" do
        report.reject! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.discard }
          .to      change { offices[0].reload.reports_rejected_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "doesn't change when rejected and transmitted report is undiscarded" do
        report.touch(:rejected_at, :discarded_at) and report.package.touch(:transmitted_at)

        expect { report.undiscard }
          .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected and transmitted report in approved package is undiscarded" do
        report.touch(:rejected_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

        expect { report.undiscard }
          .to      change { offices[0].reload.reports_rejected_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "doesn't change when rejected and transmitted report is deleted" do
        report.reject! and report.package.touch(:transmitted_at)

        expect { report.delete }
          .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
          .and not_change { offices[1].reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected and transmitted report in approved package is deleted" do
        report.reject! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.delete }
          .to      change { offices[0].reload.reports_rejected_count }.from(1).to(0)
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
      let(:report) { create(:report, commune: commune, action: Report::ACTIONS.first, subject: Report::SUBJECTS.first) }

      it "doesn't change on report creation" do
        expect { report }
          .to  not_change { offices[0].reload.reports_debated_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "doesn't change when transmitted report is debated" do
        report.package.touch(:transmitted_at)

        expect { report.debate! }
          .to  not_change { offices[0].reload.reports_debated_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when transmitted report in approved package is debated" do
        report.package.touch(:transmitted_at, :approved_at)

        expect { report.debate! }
          .to      change { offices[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "doesn't change when debated and transmitted report is discarded" do
        report.debate! and report.package.touch(:transmitted_at)

        expect { report.discard }
          .to  not_change { offices[0].reload.reports_debated_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when debated and transmitted report in approved package is discarded" do
        report.debate! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.discard }
          .to      change { offices[0].reload.reports_debated_count }.from(1).to(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "doesn't change when debated and transmitted report is undiscarded" do
        report.touch(:debated_at, :discarded_at) and report.package.touch(:transmitted_at)

        expect { report.undiscard }
          .to  not_change { offices[0].reload.reports_debated_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when debated and transmitted report in approved package is undiscarded" do
        report.touch(:debated_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

        expect { report.undiscard }
          .to      change { offices[0].reload.reports_debated_count }.from(0).to(1)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "doesn't change when debated and transmitted report is deleted" do
        report.debate! and report.package.touch(:transmitted_at)

        expect { report.delete }
          .to  not_change { offices[0].reload.reports_debated_count }.from(0)
          .and not_change { offices[1].reload.reports_debated_count }.from(0)
      end

      it "changes when debated and transmitted report in approved package is deleted" do
        report.debate! and report.package.touch(:transmitted_at, :approved_at)

        expect { report.delete }
          .to      change { offices[0].reload.reports_debated_count }.from(1).to(0)
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
