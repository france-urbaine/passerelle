# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transmissions::CreateService do
  subject(:service) do
    described_class.new(transmission)
  end

  let!(:transmission) { create(:transmission, :made_through_web_ui) }
  let!(:reports) do
    [
      create(:report, :creation_local_habitation,                 collectivity: transmission.collectivity),
      create(:report, :evaluation_local_habitation,               collectivity: transmission.collectivity),
      create(:report, :creation_local_habitation,   :transmitted, collectivity: transmission.collectivity),
      create(:report, :creation_local_habitation,   :completed,   collectivity: transmission.collectivity),
      create(:report, :evaluation_local_habitation, :completed,   collectivity: transmission.collectivity),
      create(:report, :evaluation_local_habitation, :completed,   collectivity: transmission.collectivity, transmission: transmission)
    ]
  end

  it "add transmissible reports to transmission" do
    expect {
      service.add(Report.all)
      reports.each(&:reload)
    }
      .to      change(service, :added_reports_count).from(0).to(2)
      .and     change(service, :not_added_reports_count).from(0).to(4)
      .and     change(service, :incomplete_reports_count).from(0).to(2)
      .and     change(service, :transmitted_reports_count).from(0).to(1)
      .and     change(service, :in_current_transmission_reports_count).from(0).to(1)
      .and     change(transmission.reports, :count).from(1).to(3)
      .and not_change(reports[0], :transmission_id)
      .and not_change(reports[1], :transmission_id)
      .and not_change(reports[2], :transmission_id)
      .and     change(reports[3], :transmission_id).to(transmission.id)
      .and     change(reports[4], :transmission_id).to(transmission.id)
      .and not_change(reports[5], :transmission_id)
  end
end
