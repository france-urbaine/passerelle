# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::RejectAllService do
  subject(:service) do
    described_class.new(Report.all)
  end

  let(:report) { create(:report, :transmitted_to_ddfip) }

  describe "#reject" do
    context "when reports are transmitted, without attributes" do
      it "updates all reports as rejected" do
        expect {
          result = service.reject
          report.reload
          result
        }
          .to ret(be_a(Result::Success))
          .and change(report, :state).to("rejected")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when reports are transmitted, with valid attributes" do
      it "fails to update reports" do
        expect {
          result = service.reject(reponse: "Lorem lipsum")
          report.reload
          result
        }
          .to ret(be_a(Result::Success))
          .and change(report, :state).to("rejected")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when reports are transmitted, with unexpected attributes" do
      it "fails to update reports" do
        expect {
          begin
            service.reject(priority: "high")
          ensure
            report.reload
          end
        }
          .to raise_exception(ActiveModel::UnknownAttributeError)
          .and not_change(report, :state)
          .and not_change(report, :returned_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when reports are already rejected" do
      let(:report) { create(:report, :rejected_by_ddfip) }

      it "returns a success but doesn't update the reports" do
        expect {
          result = service.reject
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("rejected")
          .and not_change(report, :returned_at)
      end
    end
  end
end
