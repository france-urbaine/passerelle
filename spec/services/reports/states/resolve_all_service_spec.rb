# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::ResolveAllService do
  subject(:service) do
    described_class.new(Report.all)
  end

  let(:report) { create(:report, :assigned_to_office) }

  describe "#resolve" do
    context "when resolving assigned reports as applicable" do
      it "updates all reports as applicable" do
        expect {
          result = service.resolve(:applicable)
          report.reload
          result
        }
          .to ret(be_a(Result::Success))
          .and change(report, :state).to("applicable")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving assigned reports as inapplicable" do
      it "updates all reports as applicable" do
        expect {
          result = service.resolve(:inapplicable)
          report.reload
          result
        }
          .to ret(be_a(Result::Success))
          .and change(report, :state).to("inapplicable")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving assigned reports, with invalid state" do
      it "fails to update reports" do
        expect {
          result = service.resolve(:approved)
          report.reload
          result
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :resolved_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors", :aggregate_failures do
        result = service.resolve(:approved)

        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:state, :inclusion) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:state, :inclusion) }
      end
    end

    context "when resolving assigned reports, with valid attributes" do
      it "updates reports" do
        expect {
          result = service.resolve(:applicable, reponse: "Lorem lipsum")
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("applicable")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolved_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when resolving assigned reports, with unexpected attributes" do
      it "fails to update reports" do
        expect {
          begin
            service.resolve(:applicable, priority: "high")
          ensure
            report.reload
          end
        }
          .to raise_exception(ActiveModel::UnknownAttributeError)
          .and not_change(report, :state)
          .and not_change(report, :resolved_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already resolved" do
      let(:report) { create(:report, :resolved_as_applicable) }

      it "returns a success but doesn't update the reports" do
        expect {
          result = service.resolve(:applicable)
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :resolved_at)
      end

      it "updates only passed attributes" do
        expect {
          result = service.resolve(:applicable, reponse: "Lorem lispum")
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("applicable")
          .and not_change(report, :resolved_at)
          .and change(report, :reponse).to("Lorem lispum")
          .and change(report, :updated_at)
      end
    end
  end
end
