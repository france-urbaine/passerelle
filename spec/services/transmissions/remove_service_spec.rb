# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transmissions::RemoveService do
  subject(:service) do
    described_class.new(transmission)
  end

  let!(:transmission) { create(:transmission, :made_through_web_ui) }
  let!(:reports) do
    [
      create(:report, :creation_local_habitation,                 collectivity: transmission.collectivity),
      create(:report, :evaluation_local_habitation,               collectivity: transmission.collectivity),
      create(:report, :creation_local_habitation,   :transmitted, collectivity: transmission.collectivity),
      create(:report, :creation_local_habitation,   :ready,   collectivity: transmission.collectivity, transmission: transmission),
      create(:report, :evaluation_local_habitation, :ready,   collectivity: transmission.collectivity, transmission: transmission),
      create(:report, :evaluation_local_habitation, :ready,   collectivity: transmission.collectivity)
    ]
  end

  it "remove relevant reports from transmission" do
    expect {
      transmission.reload
      service.remove(Report.all)
      reports.each(&:reload)
    }
      .to      change(service, :removed_reports_count).from(0).to(2)
      .and     change(transmission.reports, :count).from(2).to(0)
      .and not_change(reports[0], :transmission_id)
      .and not_change(reports[1], :transmission_id)
      .and not_change(reports[2], :transmission_id)
      .and     change(reports[3], :transmission_id).from(transmission.id).to(nil)
      .and     change(reports[4], :transmission_id).from(transmission.id).to(nil)
      .and not_change(reports[5], :transmission_id)
  end
end
