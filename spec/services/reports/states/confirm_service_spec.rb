# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::ConfirmService do
  subject(:service) do
    described_class.new(report)
  end

  let(:report) { create(:report, :resolved_as_applicable) }

  describe "#confirm" do
    context "when report is resolved as applicable" do
      it "updates the report as approved" do
        expect { service.confirm }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("approved")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is resolved as inapplicable" do
      let(:report) { create(:report, :resolved_as_inapplicable) }

      it "updates the report as canceled" do
        expect { service.confirm }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("canceled")
          .and change(report, :returned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report is already approved" do
      let(:report) { create(:report, :approved) }

      it "returns a success but doesn't update the report" do
        expect { service.confirm }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("approved")
          .and not_change(report, :returned_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when report is already canceled" do
      let(:report) { create(:report, :canceled) }

      it "returns a success but doesn't update the report" do
        expect { service.confirm }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("canceled")
          .and not_change(report, :returned_at)
          .and not_change(report, :updated_at)
      end
    end
  end
end
