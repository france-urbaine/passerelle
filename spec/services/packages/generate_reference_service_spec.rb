# frozen_string_literal: true

require "rails_helper"

RSpec.describe Packages::GenerateReferenceService do
  subject(:service) do
    described_class.new
  end

  it "generates the first reference of the month" do
    Timecop.travel(Time.zone.local(2023, 5, 26))
    expect(service.generate).to eq("2023-05-0001")
  end

  it "generates the next reference after existing packages" do
    Timecop.travel(Time.zone.local(2023, 5, 26))

    create(:package, reference: "2023-05-0001")
    create(:package, reference: "2023-05-0002")
    create(:package, reference: "2023-05-0003")

    expect(service.generate).to eq("2023-05-0004")
  end

  it "generates the first reference of the next month" do
    Timecop.travel(Time.zone.local(2023, 5, 26))
    create(:package, reference: "2023-05-0001")
    create(:package, reference: "2023-05-0002")
    create(:package, reference: "2023-05-0003")

    Timecop.travel(Time.zone.local(2023, 6, 1))
    expect(service.generate).to eq("2023-06-0001")
  end
end
