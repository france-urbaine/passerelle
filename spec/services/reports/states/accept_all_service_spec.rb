# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::AcceptAllService do
  subject(:service) do
    described_class.new(Report.all)
  end

  let(:report) { create(:report, :transmitted_to_ddfip) }

  describe "#accept" do
    context "when reports are transmitted, without attributes" do
      it "updates all reports as accepted" do
        expect {
          result = service.accept
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("accepted")
          .and change(report, :accepted_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when reports are transmitted, with unexpected attributes" do
      it "fails to update reports" do
        expect {
          begin
            service.accept(priority: "high")
          ensure
            report.reload
          end
        }.to raise_exception(ActiveModel::UnknownAttributeError)
          .and not_change(report, :state)
          .and not_change(report, :accepted_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when reports are already accepted" do
      let(:report) { create(:report, :accepted_by_ddfip) }

      it "returns a success but doesn't update the reports" do
        expect {
          result = service.accept
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :accepted_at)
      end
    end
  end
end
