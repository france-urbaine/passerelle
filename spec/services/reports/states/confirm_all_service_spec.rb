# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::States::ConfirmAllService do
  subject(:service) do
    described_class.new(Report.all)
  end

  let(:reports) do
    [
      create(:report, :resolved_as_applicable),
      create(:report, :resolved_as_inapplicable)
    ]
  end

  describe "#confirm" do
    context "when reports are resolved" do
      it "updates all reports according to their previous state" do
        expect {
          result = service.confirm
          reports.each(&:reload)
          result
        }
          .to ret(be_a(Result::Success))
          .and change(reports[0], :state).to("approved")
          .and change(reports[1], :state).to("canceled")
          .and change(reports[0], :returned_at).to(be_present)
          .and change(reports[0], :updated_at)
      end
    end

    context "when reports are resolved, with valid attributes" do
      it "fails to update reports" do
        expect {
          result = service.confirm(reponse: "Lorem lipsum")
          reports.each(&:reload)
          result
        }
          .to ret(be_a(Result::Success))
          .and change(reports[0], :state).to("approved")
          .and change(reports[1], :state).to("canceled")
          .and change(reports[0], :reponse).to("Lorem lipsum")
          .and change(reports[1], :reponse).to("Lorem lipsum")
          .and change(reports[0], :returned_at).to(be_present)
          .and change(reports[0], :updated_at)
      end
    end

    context "when reports are transmitted, with unexpected attributes" do
      it "fails to update reports" do
        expect {
          begin
            service.confirm(priority: "high")
          ensure
            reports.each(&:reload)
          end
        }
          .to raise_exception(ActiveModel::UnknownAttributeError)
          .and not_change(reports[0], :state)
          .and not_change(reports[0], :returned_at)
          .and not_change(reports[0], :updated_at)
      end
    end

    context "when reports are already confirmed" do
      let(:reports) do
        [
          create(:report, :approved),
          create(:report, :canceled)
        ]
      end

      it "returns a success but doesn't update the reports" do
        expect {
          result = service.confirm
          reports.each(&:reload)
          result
        }
          .to  ret(be_a(Result::Success))
          .and not_change(reports[0], :state).from("approved")
          .and not_change(reports[1], :state).from("canceled")
          .and not_change(reports[0], :returned_at)
      end
    end
  end
end
