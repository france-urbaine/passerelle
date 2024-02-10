# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::ResolveService do
  subject(:service) do
    described_class.new(report)
  end

  let(:report) { create(:report, :assigned_to_office) }

  describe "#resolve" do
    context "when resolving an assigned report as applicable" do
      it "updates the report as applicable" do
        expect { service.resolve(:applicable) }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("applicable")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving an assigned report as inapplicable" do
      it "updates the report as inapplicable" do
        expect { service.resolve(:inapplicable) }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("inapplicable")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving an assigned report, with valid attributes" do
      it "updates the report" do
        expect { service.resolve(:applicable, reponse: "Lorem lipsum") }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("applicable")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving an assigned report, with invalid attributes" do
      it "fails to update the report" do
        expect { service.resolve(:applicable, priority: "unkown") }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :resolved_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors", :aggregate_failures do
        result = service.resolve(:applicable, priority: "unkown")

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:priority, :inclusion) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:priority, :inclusion) }
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :resolved_as_applicable) }

      it "updates the report resolution" do
        expect { service.resolve(:inapplicable) }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("inapplicable")
          .and change(report, :resolved_at)
          .and change(report, :updated_at)
      end

      it "doesn't updates the report when it's the same resolution" do
        expect { service.resolve(:applicable) }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :resolved_at)
          .and not_change(report, :updated_at)
      end

      it "updates only passed attributes when it's the same resolution" do
        expect { service.resolve(:applicable, reponse: "Lorem lipsum") }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :resolved_at)
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :updated_at)
      end
    end

    context "when report is already confirmed" do
      let(:report) { create(:report, :approved) }

      it "fails to update the report" do
        expect { service.resolve(:inapplicable) }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("approved")
          .and not_change(report, :resolved_at)
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.resolve(:inapplicable)

        expect(report.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end

  describe "#undo" do
    context "when report is resolved" do
      let(:report) { create(:report, :assigned, :applicable) }

      it "updates the report back as assigned" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("assigned")
          .and change(report, :resolved_at).to(nil)
          .and change(report, :updated_at)
      end
    end

    context "when report is not resolved anymore" do
      let(:report) { create(:report, :assigned) }

      it "returns a success without updating the report" do
        expect { service.undo }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :assigned_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already confirmed" do
      let(:report) { create(:report, :approved) }

      it "fails to update the report" do
        expect { service.undo }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("approved")
          .and not_change(report, :updated_at)
      end

      it "assigns errors about invalid state transition", :aggregate_failures do
        result = service.undo

        expect(report.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
        expect(result.errors).to satisfy { |errors| errors.of_kind?(:state, :invalid_transition) }
      end
    end
  end
end
