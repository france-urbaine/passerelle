# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transmissions::CompleteService do
  subject(:service) do
    described_class.new(transmission)
  end

  let!(:ddfip)    { create(:ddfip) }
  let!(:office)   { create(:office, competences: %w[evaluation_local_habitation creation_local_habitation], ddfip: ddfip, communes: communes[0..0]) }
  let!(:communes) { create_list(:commune, 2, departement: ddfip.departement) }

  let!(:transmission) { create(:transmission) }
  let!(:reports) do
    [
      create(:report, :ready, :evaluation_local_habitation, commune: communes[0], transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :ready, :evaluation_local_habitation, commune: communes[1], transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :ready, :creation_local_habitation,   commune: communes[0], transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :ready, :occupation_local_habitation, commune: communes[0], transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :ready, :evaluation_local_habitation, transmission: transmission, collectivity: transmission.collectivity)
    ]
  end

  around do |e|
    # Wrap the whole example and all `let!` in the same year:
    # - to check expected year in references
    # - to ensure reports are created with the expected `situation_annee_majic`
    #
    Timecop.travel(2023, 12, 13) do
      e.run
    end
  end

  before do
    # Add polution data
    create(:ddfip)
    create(:office, ddfip: ddfip, competences: %w[evaluation_local_habitation creation_local_habitation])
  end

  describe "#complete" do
    it "creates packages, set references and update transmission completed_at" do
      expect {
        service.complete
        reports.each(&:reload)
      }
        .to change(Package,         :count).by(1)
        .and change(reports[0],     :reference).to("2023-12-0001-00001")
        .and change(reports[1],     :reference).to("2023-12-0001-00002")
        .and change(reports[2],     :reference).to("2023-12-0001-00003")
        .and change(reports[3],     :reference).to("2023-12-0001-00004")
        .and not_change(reports[4], :reference).from(nil)
    end

    it "updates transmission completed_at" do
      expect {
        service.complete
        transmission.reload
      }.to change(transmission, :completed_at).to(be_present)
    end

    it "assigns office for each report when covered by one" do
      expect {
        service.complete
        reports.each(&:reload)
      }.to change(reports[0],       :office).to(office)
        .and not_change(reports[1], :office).from(nil)
        .and change(reports[2],     :office).to(office)
        .and not_change(reports[3], :office).from(nil)
        .and not_change(reports[4], :office).from(nil)
    end

    it "assigns ddfip for each report when covered by one" do
      expect {
        service.complete
        reports.each(&:reload)
      }.to change(reports[0],       :ddfip).to(ddfip)
        .and change(reports[1],     :ddfip).to(ddfip)
        .and change(reports[2],     :ddfip).to(ddfip)
        .and change(reports[3],     :ddfip).to(ddfip)
        .and not_change(reports[4], :ddfip).from(nil)
    end

    it "enqueues a job to send a notification" do
      expect {
        service.complete
      }.to have_enqueued_job(NotifyTransmissionCompletedJob)
    end

    context "when auto-assignment is activated" do
      let(:ddfip) { create(:ddfip, auto_assign_reports: true) }

      it "bypasses acceptation and set state to assigned to those reports we can assign an office" do
        expect {
          service.complete
          reports.each(&:reload)
        }.to   change(reports[0], :state).to("assigned")
          .and change(reports[1], :state).to("transmitted")
          .and change(reports[2], :state).to("assigned")
          .and change(reports[3], :state).to("transmitted")
      end
    end

    context "when transmission is sandbox" do
      before do
        transmission.update(sandbox: true)
      end

      it "creates packages, assigns reports and complete transmission" do
        expect {
          service.complete
          reports.each(&:reload)
        }
          .to  change(Package, :count).by(1)
          .and change(reports[0],     :reference).to(be_present)
          .and change(reports[1],     :reference).to(be_present)
          .and change(reports[2],     :reference).to(be_present)
          .and change(reports[3],     :reference).to(be_present)
          .and not_change(reports[4], :reference).from(nil)
          .and change(transmission,   :completed_at).to(be_present)
      end

      it "create packages with transmission sandbox value" do
        service.complete
        reports.each(&:reload)

        expect(transmission.packages.first(2).all?(&:sandbox?)).to be(true)
      end
    end
  end

  describe "#generate_reference" do
    it "generates the first reference of the month" do
      Timecop.travel(2023, 5, 26) do
        expect(service.send(:generate_package_reference)).to eq("2023-05-0001")
      end
    end

    it "generates the next reference after existing packages" do
      Timecop.travel(2023, 5, 26) do
        create(:package, reference: "2023-05-0001")
        create(:package, reference: "2023-05-0002")
        create(:package, reference: "2023-05-0003")

        expect(service.send(:generate_package_reference)).to eq("2023-05-0004")
      end
    end

    it "generates the first reference of the next month" do
      Timecop.travel(2023, 5, 26) do
        create(:package, reference: "2023-05-0001")
        create(:package, reference: "2023-05-0002")
        create(:package, reference: "2023-05-0003")

        Timecop.travel(2023, 6, 1) do
          expect(service.send(:generate_package_reference)).to eq("2023-06-0001")
        end
      end
    end
  end
end
