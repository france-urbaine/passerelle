# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::StateService do
  subject(:service) do
    described_class.new(report)
  end

  describe "#assign" do
    context "with valid attributes" do
      let(:report)     { create(:report, :transmitted_to_ddfip) }
      let(:office)     { create(:office, ddfip: report.ddfip) }
      let(:attributes) { { office_id: office.id } }

      it "updates the report as processing" do
        expect {
          service.assign(attributes)
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("processing")
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :office_id).to(office.id)
      end
    end

    context "with missing office" do
      let(:report)     { create(:report, :transmitted_to_ddfip) }
      let(:attributes) { { office_id: nil } }

      it "fails to update the report when office is missing" do
        expect {
          service.assign(attributes)
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("sent")
          .and not_change(report, :assigned_at).from(nil)
      end

      it "assigns errors about missing office" do
        service.assign(attributes)
        expect(report.errors).to satisfy { |errors| errors.of_kind?(:office_id, :blank) }
      end
    end

    context "when report is already assigned" do
      let(:report)     { create(:report, :assigned_by_ddfip) }
      let(:office)     { create(:office, ddfip: report.ddfip) }
      let(:attributes) { { office_id: office.id } }

      it "keeps the report assigned but updates only its office" do
        expect {
          service.assign(attributes)
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and not_change(report, :state).from("processing")
          .and not_change(report, :assigned_at)
          .and change(report, :office_id).to(office.id)
      end
    end

    context "when report is already approved" do
      let(:report)     { create(:report, :transmitted_to_ddfip, :approved) }
      let(:office)     { create(:office, ddfip: report.ddfip) }
      let(:attributes) { { office_id: office.id } }

      it "fails to update the report when office is missing" do
        expect {
          service.assign(attributes)
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
      end

      it "assigns errors about invalid state transition" do
        service.assign(attributes)
        expect(report.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#unassign" do
    context "when report is assigned" do
      let(:report) { create(:report, :assigned_by_ddfip) }

      it "updates the report back as acknowledged" do
        expect {
          service.unassign
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("acknowledged")
          .and change(report, :assigned_at).to(nil)
          .and not_change(report, :office_id)
      end
    end

    context "when report is already unassigned" do
      let(:report) { create(:report, :transmitted_to_ddfip, :acknowledged) }

      it "keeps the report acknowledged" do
        expect {
          service.unassign
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("acknowledged")
          .and not_change(report, :acknowledged_at)
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :transmitted_to_ddfip, :approved) }

      it "fails to update the report when office is missing" do
        expect {
          service.unassign
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
      end

      it "assigns errors about invalid state transition" do
        service.unassign
        expect(report.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#deny" do
    context "with valid attributes" do
      let(:report)     { create(:report, :assigned) }
      let(:attributes) { { reponse: "Lorem lipsum" } }

      it "updates the report as denied" do
        expect {
          service.deny(attributes)
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and change(report, :reponse).to("Lorem lipsum")
      end
    end

    context "with missing response" do
      let(:report)     { create(:report, :assigned) }
      let(:attributes) { { reponse: nil } }

      it "updates the report as denied" do
        expect {
          service.deny(attributes)
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and not_change(report, :reponse)
      end
    end

    context "when report is already denied" do
      let(:report)     { create(:report, :denied) }
      let(:attributes) { { reponse: "Lorem lipsum" } }

      it "keeps the report denied but updates only its response" do
        expect {
          service.deny(attributes)
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and not_change(report, :state).from("denied")
          .and not_change(report, :denied_at)
          .and change(report, :reponse).to("Lorem lipsum")
      end
    end

    context "when report is already approved" do
      let(:report)     { create(:report, :transmitted_to_ddfip, :approved) }
      let(:office)     { create(:office, ddfip: report.ddfip) }
      let(:attributes) { { office_id: office.id } }

      it "fails to update the report when office is missing" do
        expect {
          service.deny(attributes)
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
      end

      it "assigns errors about invalid state transition" do
        service.deny(attributes)
        expect(report.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#undeny" do
    context "when report is denied" do
      let(:report) { create(:report, :denied) }

      it "updates the report back as acknowledged" do
        expect {
          service.undeny
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("acknowledged")
          .and change(report, :denied_at).to(nil)
      end
    end

    context "when report is already undenied" do
      let(:report) { create(:report, :transmitted_to_ddfip, :acknowledged) }

      it "keeps the report acknowledged" do
        expect {
          service.undeny
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("acknowledged")
          .and not_change(report, :acknowledged_at)
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :transmitted_to_ddfip, :approved) }

      it "fails to update the report when office is missing" do
        expect {
          service.undeny
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
      end

      it "assigns errors about invalid state transition" do
        service.undeny
        expect(report.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#approve" do
    context "when report is assigned" do
      let(:report) { create(:report, :assigned) }

      it "updates the report as approved" do
        expect {
          service.approve
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("approved")
          .and change(report, :approved_at).to(be_present)
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :approved) }

      it "keeps the report approved" do
        expect {
          service.approve
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
          .and not_change(report, :approved_at)
      end
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected) }

      it "updates the report as approved" do
        expect {
          service.approve
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("approved")
          .and change(report, :approved_at).to(be_present)
          .and change(report, :rejected_at).to(nil)
      end
    end
  end

  describe "#unapprove" do
    context "when report is approved" do
      let(:report) { create(:report, :approved) }

      it "updates the report back as assigned" do
        expect {
          service.unapprove
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("processing")
          .and change(report, :approved_at).to(nil)
      end
    end

    context "when report is already unapproved" do
      let(:report) { create(:report, :assigned) }

      it "keeps the report assigned" do
        expect {
          service.unapprove
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("processing")
      end
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected) }

      it "updates the report as approved" do
        expect {
          service.unapprove
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("rejected")
      end
    end
  end

  describe "#reject" do
    context "when report is assigned" do
      let(:report) { create(:report, :assigned) }

      it "updates the report as rejected" do
        expect {
          service.reject
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("rejected")
          .and change(report, :rejected_at).to(be_present)
      end
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected) }

      it "keeps the report rejected" do
        expect {
          service.reject
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("rejected")
          .and not_change(report, :rejected_at)
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :approved) }

      it "updates the report as approved" do
        expect {
          service.reject
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("rejected")
          .and change(report, :rejected_at).to(be_present)
          .and change(report, :approved_at).to(nil)
      end
    end
  end

  describe "#unreject" do
    context "when report is rejected" do
      let(:report) { create(:report, :rejected) }

      it "updates the report back as assigned" do
        expect {
          service.unreject
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :updated_at)
          .and change(report, :state).to("processing")
          .and change(report, :rejected_at).to(nil)
      end
    end

    context "when report is already unrejected" do
      let(:report) { create(:report, :assigned) }

      it "keeps the report assigned" do
        expect {
          service.unreject
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("processing")
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :approved) }

      it "updates the report as approved" do
        expect {
          service.unreject
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :updated_at)
          .and not_change(report, :state).from("approved")
      end
    end
  end
end
