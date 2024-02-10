# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::RejectService do
  subject(:service) do
    described_class.new(report)
  end

  let(:report) { create(:report, :transmitted) }

  describe "#deny" do
    context "when report is transmitted, without attributes" do
      it "updates the report as rejected" do
        expect { service.reject }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("rejected")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is transmitted, with valid attributes" do
      it "updates the report as rejected" do
        expect { service.reject(reponse: "Lorem lipsum") }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("rejected")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is transmitted, with invalid attributes" do
      it "fails to update the report" do
        expect { service.reject(priority: "unkown") }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("transmitted")
          .and not_change(report, :returned_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors", :aggregate_failures do
        result = service.reject(priority: "unkown")

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:priority, :inclusion) }
      end
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected) }

      it "returns a success but doesn't update the report" do
        expect { service.reject }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("rejected")
          .and not_change(report, :returned_at)
          .and not_change(report, :updated_at)
      end

      it "updates only passed attributes" do
        expect { service.reject(reponse: "Lorem lipsum") }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("rejected")
          .and not_change(report, :returned_at)
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :resolved_as_applicable) }

      it "fails to update the report" do
        expect { service.reject }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.reject

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#undo" do
    context "when the report is rejected" do
      let(:report) { create(:report, :rejected) }

      it "updates the report back as acknowledged" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("acknowledged")
          .and change(report, :returned_at).to(nil)
          .and change(report, :updated_at)
      end
    end

    context "when report is not rejected anymore" do
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
