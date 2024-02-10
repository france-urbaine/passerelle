# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::AcceptService do
  subject(:service) do
    described_class.new(report)
  end

  let(:report) { create(:report, :transmitted) }

  describe "#accept" do
    context "when report is transmitted, without attributes" do
      it "updates the report as accepted" do
        expect { service.accept }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("accepted")
          .and change(report, :accepted_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is transmitted, with valid attributes" do
      it "updates the report as accepted" do
        expect { service.accept(priority: "high") }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("accepted")
          .and change(report, :priority).to("high")
          .and change(report, :accepted_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is transmitted, with invalid attributes" do
      it "fails to update the report" do
        expect { service.accept(priority: "unkown") }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("transmitted")
          .and not_change(report, :accepted_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors", :aggregate_failures do
        result = service.accept(priority: "unkown")

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:priority, :inclusion) }
      end
    end

    context "when report is already accepted" do
      let(:report) { create(:report, :accepted) }

      it "returns a success but doesn't update the report" do
        expect { service.accept }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :accepted_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :resolved_as_applicable) }

      it "fails to update the report" do
        expect { service.accept }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :accepted_at)
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.accept

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#undo" do
    context "when report is accepted" do
      let(:report) { create(:report, :accepted) }

      it "updates the report back as acknowledged" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("acknowledged")
          .and change(report, :accepted_at).to(nil)
          .and change(report, :updated_at)
      end
    end

    context "when report is not accepted anymore" do
      let(:report) { create(:report, :acknowledged) }

      it "returns a success without updating the report" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("acknowledged")
          .and not_change(report, :acknowledged_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :assigned, :applicable) }

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
