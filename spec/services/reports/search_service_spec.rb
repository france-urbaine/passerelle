# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::SearchService do
  subject(:service) do
    described_class.new
  end

  describe "#analyze_param" do
    it "converts states based on those a collectivity can see" do
      expect(
        described_class.new(as: :collectivity).analyze_param("etat:(Signalement accepté) Bayonne")
      ).to eq(
        "state:(accepted,assigned,applicable,inapplicable) Bayonne"
      )
    end

    it "converts states based on those a DDFIP can see" do
      expect(
        described_class.new(as: :ddfip_admin).analyze_param("etat:accepté Bayonne")
      ).to eq(
        "state:accepted Bayonne"
      )
    end

    it "converts a Hash but keep comma in values" do
      expect(
        service.analyze_param(state: "accepted,assigned")
      ).to eq(
        "state" => "accepted,assigned"
      )
    end

    it "keeps values not handled by the converter" do
      expect(
        service.analyze_param("invariant:1234 formulaire:(local pro)")
      ).to eq(
        "invariant" => "1234",
        "form_type" => "local pro"
      )
    end
  end
end
