# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::AssignAllService do
  subject(:service) do
    described_class.new(Report.all)
  end

  let(:report) { create(:report, :accepted_by_ddfip) }

  describe "#assign" do
    let(:office) { create(:office, ddfip: report.ddfip) }

    context "when report are accepted, with valid attributes" do
      it "updates the report as assigned" do
        expect {
          result = service.assign(office_id: office.id)
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and change(report, :state).to("assigned")
          .and change(report, :office_id).to(office.id)
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :updated_at)
      end
    end

    context "when report are accepted, without office attribute" do
      it "fails to update the report" do
        expect {
          result = service.assign
          report.reload
          result
        }
          .to  ret(be_a(Result::Failure))
          .and not_change(report, :state).from("accepted")
          .and not_change(report, :assigned_at).from(nil)
          .and not_change(report, :updated_at)
      end

      it "assigns errors about missing office", :aggregate_failures do
        result = service.assign

        expect(result.errors).to satisfy  { |errors| errors.of_kind?(:office_id, :blank) }
        expect(service.errors).to satisfy { |errors| errors.of_kind?(:office_id, :blank) }
      end
    end

    context "when reports are accepted, with unexpected attributes" do
      it "updates all reports as accepted" do
        expect {
          begin
            service.assign(office_id: office.id, priority: "high")
          ensure
            report.reload
          end
        }.to raise_exception(ActiveModel::UnknownAttributeError)
          .and not_change(report, :state)
          .and not_change(report, :assigned_at)
          .and not_change(report, :updated_at)
      end
    end

    context "when reports are already assigned" do
      let(:report) { create(:report, :assigned_to_office) }

      it "returns a success but doesn't update the reports" do
        expect {
          result = service.assign(office_id: report.office_id)
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :accepted_at)
      end

      it "updates only passed attributes" do
        expect {
          result = service.assign(office_id: office.id)
          report.reload
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(report, :state).from("assigned")
          .and not_change(report, :assigned_at)
          .and change(report, :office_id).to(office.id)
          .and change(report, :updated_at)
      end
    end
  end
end
