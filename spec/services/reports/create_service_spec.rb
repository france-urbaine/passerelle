# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CreateService do
  subject(:service) do
    described_class.new(report, user, attributes)
  end

  let(:report)       { Report.new }
  let(:collectivity) { create(:collectivity) }
  let(:user)         { create(:user, organization: collectivity) }
  let(:attributes)   { { form_type: "evaluation_local_habitation" } }

  it "creates a report" do
    expect { service.save }
      .to  change(Report, :count).by(1)
      .and change(report, :persisted?).from(false).to(true)
      .and not_change(Package, :count)
  end

  # it "creates a package and a report" do
  #   expect { service.save }
  #     .to  change(Package, :count).by(1)
  #     .and change(Report, :count).by(1)
  #     .and change(report, :persisted?).from(false).to(true)
  #     .and change(report, :package).to(be_present)
  # end

  # it "assigns expected attributes" do
  #   Timecop.travel(Time.zone.local(2023, 5, 26))
  #   service.save

  #   aggregate_failures do
  #     expect(report.collectivity).to be(collectivity)
  #     expect(report.package).to have_attributes(
  #       form_type: attributes[:form_type],
  #       reference:  "2023-05-0001"
  #     )
  #     expect(report).to have_attributes(
  #       form_type: attributes[:form_type],
  #       reference: "2023-05-0001-00001"
  #     )
  #   end
  # end

  # it "increments reference when existing package has already some reports" do
  #   Timecop.travel(Time.zone.local(2023, 5, 26))
  #   FactoryBot.rewind_sequences
  #   create(:package, :evaluation_local_habitation, :with_reports, report_size: 3, collectivity: collectivity, reference: "2023-05-0003")

  #   service.save
  #   expect(report).to have_attributes(reference: "2023-05-0003-00004")
  # end
end
