# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserParamsParser do
  subject(:parser) do
    described_class.new(payload)
  end

  context "when using organization_id" do
    it "returns the same payload" do
      payload = {
        organization_type: "Publisher",
        organization_id:   "12345",
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(payload)
    end
  end

  context "when using organization_data in JSON" do
    it "replaces the JSON payload by an ID and its type" do
      payload = {
        organization_data: { type: "Publisher", id: "123456" }.to_json,
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "Publisher",
        organization_id:   "123456",
        someting_else:     "true"
      )
    end
  end

  context "when using organization_name" do
    it "replaces the name of a Publisher by its ID" do
      publisher = create(:publisher)
      payload = {
        organization_type: "Publisher",
        organization_name: publisher.name,
        organization_id:   "1",
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "Publisher",
        organization_id:   publisher.id,
        someting_else:     "true"
      )
    end

    it "replaces the name of a DDFIP by its ID" do
      ddfip = create(:ddfip)
      payload = {
        organization_type: "DDFIP",
        organization_name: ddfip.name,
        organization_id:   "1",
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "DDFIP",
        organization_id:   ddfip.id,
        someting_else:     "true"
      )
    end

    it "replaces the name of a Collectivity by its ID" do
      collectivity = create(:collectivity)
      payload = {
        organization_type: "Collectivity",
        organization_name: collectivity.name,
        organization_id:   "1",
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "Collectivity",
        organization_id:   collectivity.id,
        someting_else:     "true"
      )
    end

    it "removes an unknown name and let the ID empty" do
      payload = {
        organization_type: "Publisher",
        organization_name: "Inconnue",
        organization_id:   "1",
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "Publisher",
        organization_id:   nil,
        someting_else:     "true"
      )
    end
  end

  context "when using office_ids" do
    it "returns the same payload when IDs belong to DDFIP's users" do
      ddfip   = create(:ddfip)
      offices = create_list(:office, 2, ddfip: ddfip)
      payload = {
        organization_type: "DDFIP",
        organization_id:   ddfip.id,
        office_ids:        offices.map(&:id),
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(payload)
    end

    it "returns the same payload when using DDFIP's name" do
      ddfip   = create(:ddfip)
      offices = create_list(:office, 2, ddfip: ddfip)
      payload = {
        organization_type: "DDFIP",
        organization_name: ddfip.name,
         office_ids:       offices.map(&:id),
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "DDFIP",
        organization_id:   ddfip.id,
        office_ids:        offices.map(&:id),
        someting_else:     "true"
      )
    end

    it "removes IDs of users which are not belonging to DDFIP" do
      ddfip   = create(:ddfip)
      office1 = create(:office, ddfip: ddfip)
      office2 = create(:office)

      payload = {
        organization_type: "DDFIP",
        organization_id:   ddfip.id,
        office_ids:        [office1.id, office2.id],
        someting_else:     "true"
      }

      expect(described_class.new(payload).parse).to eq(
        organization_type: "DDFIP",
        organization_id:   ddfip.id,
        office_ids:        [office1.id],
        someting_else:     "true"
      )
    end
  end
end
