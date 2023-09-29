# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transmissions::CompleteService do
  subject(:service) do
    described_class.new(transmission)
  end

  let(:transmission) { create(:transmission, :made_through_web_ui) }
  let(:reports) do
    [
      create(:report, :completed, :evaluation_local_habitation, transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :completed, :evaluation_local_habitation, transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :completed, :creation_local_habitation, transmission: transmission, collectivity: transmission.collectivity)
    ]
  end

  before do
    reports.each { |report| report.update(package: nil, reference: nil) }
  end

  it "creates packages, assigns reports and complete transmission" do
    expect {
      service.save
      reports.each(&:reload)
    }
      .to  change(Package, :count).by(2)
      .and change(reports[0], :reference).to(be_present)
      .and change(reports[1], :reference).to(be_present)
      .and change(reports[2], :reference).to(be_present)
      .and change(transmission, :completed_at).to(be_present)
  end
end
