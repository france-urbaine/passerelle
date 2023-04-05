# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectivityParamsParser do
  subject(:parser) do
    described_class.new(input)
  end

  context "when using territory_id" do
    it "doesn't update params" do
      input = {
        territory_type: "Commune",
        territory_id:   "12345",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(input)
    end
  end

  context "when using territory_data in JSON" do
    it "replaces the JSON payload by an ID and its type" do
      input = {
        territory_data: { type: "Commune", id: "123456" }.to_json,
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "Commune",
        territory_id:   "123456",
        someting_else:  "true"
      )
    end
  end

  context "when using territory_code" do
    it "replaces the code of a Commune by its ID" do
      commune = create(:commune)
      input = {
        territory_type: "Commune",
        territory_code: commune.code_insee,
        territory_id:   "1",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "Commune",
        territory_id:   commune.id,
        someting_else:  "true"
      )
    end

    it "replaces the SIREN of an EPCI by its ID" do
      epci = create(:epci)
      input = {
        territory_type: "EPCI",
        territory_code: epci.siren,
        territory_id:   "1",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "EPCI",
        territory_id:   epci.id,
        someting_else:  "true"
      )
    end

    it "replaces the code of a Departement by its ID" do
      departement = create(:departement)
      input = {
        territory_type: "Departement",
        territory_code: departement.code_departement,
        territory_id:   "1",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "Departement",
        territory_id:   departement.id,
        someting_else:  "true"
      )
    end

    it "replaces the code of a Region by its ID" do
      region = create(:region)
      input = {
        territory_type: "Region",
        territory_code: region.code_region,
        territory_id:   "1",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "Region",
        territory_id:   region.id,
        someting_else:  "true"
      )
    end

    it "removes an invalid code and let ID empty" do
      input = {
        territory_type: "Commune",
        territory_code: "640102",
        territory_id:   "1",
        someting_else:  "true"
      }

      expect(described_class.new(input).parse).to eq(
        territory_type: "Commune",
        territory_id:   nil,
        someting_else:  "true"
      )
    end
  end
end
