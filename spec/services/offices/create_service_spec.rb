# frozen_string_literal: true

require "rails_helper"

RSpec.describe Offices::CreateService do
  subject(:service) do
    described_class.new(office, attributes)
  end

  let(:office) { Office.new }
  let(:ddfip)  { create(:ddfip) }

  let(:attributes) do
    {
      ddfip_id:    ddfip.id,
      name:        Faker::Company.name,
      competences: Office::COMPETENCES.sample(1)
    }
  end

  it "returns a successful result" do
    expect(service.save).to be_successful
  end

  it "creates the office" do
    expect { service.save }
      .to  change(Office, :count).by(1)
      .and change(office, :persisted?).from(false).to(true)
  end

  it "assigns expected attributes" do
    service.save
    office.reload

    expect(office).to have_attributes(
      ddfip:       ddfip,
      name:        attributes[:name],
      competences: attributes[:competences]
    )
  end

  context "with invalid arguments" do
    let(:attributes) do
      { name: "" }
    end

    it "returns a failed result with errors" do
      result = service.save

      aggregate_failures do
        expect(result).to be_failed
        expect(result.errors).to be_any
      end
    end

    it "doesn't create an office" do
      expect { service.save }
        .to  not_change(Office, :count)
        .and not_change(office, :persisted?).from(false)
    end
  end

  context "with a given ddfip" do
    subject(:service) do
      described_class.new(office, attributes, ddfip: another_ddfip)
    end

    let(:another_ddfip) { create(:ddfip) }

    it "creates an office with the given ddfip instead of the one passed" do
      expect { service.save }
        .to change(office, :ddfip).to(another_ddfip)
    end
  end

  context "when using ddfip_name" do
    let(:attributes) do
      {
        ddfip_name:  ddfip.name,
        name:        Faker::Company.name,
        competences: Office::COMPETENCES.sample(1)
      }
    end

    it "creates an office with expected ddfip" do
      expect { service.save }
        .to change(office, :ddfip).to(ddfip)
    end

    it "returns a validation error on invalid name" do
      service = described_class.new(office, { ddfip_name: "" })
      service.validate
      expect(service.errors).to include(:ddfip)
    end
  end
end
