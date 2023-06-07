# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CreateService do
  subject(:service) do
    described_class.new(report, collectivity, attributes)
  end

  let(:report)       { Report.new }
  let(:collectivity) { create(:collectivity) }
  let(:attributes)   { { subject: "evaluation_hab/evaluation" } }

  it "creates a package and a report" do
    expect { service.save }
      .to  change(Package, :count).by(1)
      .and change(Report, :count).by(1)
      .and change(report, :persisted?).from(false).to(true)
      .and change(report, :package).to(be_present)
  end

  it "assigns an existing package when action matches and is still packing" do
    package = create(:package, collectivity: collectivity, action: "evaluation_hab")

    expect { service.save }
      .to  not_change(Package, :count).from(1)
      .and change(Report, :count).by(1)
      .and change(report, :package).to(package)
  end

  it "doesn't assign an existing package when action doesn't match" do
    package = create(:package, collectivity: collectivity, action: "evaluation_eco")

    expect { service.save }
      .to  change(Package, :count).by(1)
      .and change(Report, :count).by(1)
      .and change(report, :package).to(be_present.and(not_eq(package)))
  end

  it "doesn't assign an existing package when it's already transmitted" do
    package = create(:package, :transmitted, collectivity: collectivity, action: "evaluation_hab")

    expect { service.save }
      .to  change(Package, :count).by(1)
      .and change(Report, :count).by(1)
      .and change(report, :package).to(be_present.and(not_eq(package)))
  end

  it "doesn't assign an existing package which belong to another collectivity" do
    package = create(:package, action: "evaluation_hab")

    expect { service.save }
      .to  change(Package, :count).by(1)
      .and change(Report, :count).by(1)
      .and change(report, :package).to(be_present.and(not_eq(package)))
  end

  it "assigns expected attributes" do
    Timecop.travel(Time.zone.local(2023, 5, 26))
    service.save

    aggregate_failures do
      expect(report.collectivity).to be(collectivity)
      expect(report.package).to have_attributes(
        action:    "evaluation_hab",
        reference: "2023-05-0001"
      )
      expect(report).to have_attributes(
        subject:   "evaluation_hab/evaluation",
        action:    "evaluation_hab",
        reference: "2023-05-0001-00001"
      )
    end
  end

  it "increments reference when existing package has already some reports" do
    Timecop.travel(Time.zone.local(2023, 5, 26))
    FactoryBot.rewind_sequences
    create(:package, :with_reports, report_size: 3, collectivity: collectivity, action: "evaluation_hab", reference: "2023-05-0003")

    service.save
    expect(report).to have_attributes(reference: "2023-05-0003-00004")
  end
end
