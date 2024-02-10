# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::AssignService do
  subject(:service) do
    described_class.new(report)
  end

  let(:report) { create(:report, :accepted_by_ddfip) }

  describe "#assign" do
    let(:office) { create(:office, ddfip: report.ddfip) }

    context "when report is accepted, with valid attributes" do
      it "updates the report as assigned" do
        expect { service.assign(office_id: office.id) }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("assigned")
          .and change(report, :office_id).to(office.id)
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is accepted, without office attribute" do
      it "fails to update the report" do
        expect { service.assign }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :assigned_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors about missing office", :aggregate_failures do
        result = service.assign

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:office_id, :blank) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:office_id, :blank) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:office_id, :blank) }
      end
    end

    context "when report is accepted, with invalid attributes" do
      it "fails to update the report" do
        expect { service.assign(priority: "unkown") }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :assigned_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors", :aggregate_failures do
        result = service.assign(priority: "unkown")

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:priority, :inclusion) }
      end
    end

    context "when report is already assigned" do
      let(:report) { create(:report, :assigned_to_office) }

      it "returns a success but doesn't update the report" do
        expect { service.assign(office_id: report.office_id) }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :updated_at)
      end

      it "updates only passed attributes" do
        expect { service.assign(office_id: office.id) }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :assigned_at)
          .and change(report, :office_id).to(office.id)
          .and change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :resolved_as_applicable) }

      it "fails to update the report" do
        expect { service.assign(office_id: office.id) }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.assign(office_id: office.id)

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#undo" do
    context "when report is assigned" do
      let(:report) { create(:report, :assigned_by_ddfip) }

      it "updates the report back as accepted" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("accepted")
          .and change(report, :assigned_at).to(nil)
          .and change(report, :updated_at)
          .and not_change(report, :office_id)
      end
    end

    context "when report is not assigned anymore" do
      let(:report) { create(:report, :accepted_by_ddfip) }

      it "returns a success without updating the report" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :accepted_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :assigned_by_ddfip, :applicable) }

      it "fails to update the report" do
        expect { service.undo }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.undo

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end
end
