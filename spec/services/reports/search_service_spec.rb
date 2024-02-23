# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::SearchService do
  subject(:service) do
    described_class.new
  end

  describe "#analyze_param" do
    it "converts states based on those a collectivity can see" do
      expect(
        described_class.new(as: :collectivity).analyze_param("état:(Signalement accepté) Bayonne")
      ).to eq(
        "state:(accepted,assigned,applicable,inapplicable) Bayonne"
      )
    end

    it "converts states based on those a DDFIP can see" do
      expect(
        described_class.new(as: :ddfip_admin).analyze_param("état:accepté Bayonne")
      ).to eq(
        "state:accepted Bayonne"
      )
    end

    it "converts form_types" do
      expect(
        service.analyze_param("type:(local pro)")
      ).to eq(
        "form_type" => %w[
          evaluation_local_professionnel
          creation_local_professionnel
          occupation_local_professionnel
        ]
      )
    end

    it "converts anomalies" do
      expect(
        service.analyze_param("objet:(Omission bâtie,Changement de consistance,Foo)")
      ).to eq(
        "anomalies" => %w[omission_batie consistance foo]
      )
    end

    it "converts priorities" do
      expect(
        service.analyze_param("priorité:haute")
      ).to eq(
        "priority" => %w[high]
      )
    end

    it "converts a Hash but keep comma in values" do
      expect(
        service.analyze_param(state: "accepted,assigned")
      ).to eq(
        "state" => "accepted,assigned"
      )
    end

    it "keeps criteria not handled by the converter" do
      expect(
        service.analyze_param("invariant:1234 commune:(Bayonne,Anglet)")
      ).to eq(
        "invariant" => "1234",
        "commune"   => %w[Bayonne Anglet]
      )
    end
  end
end
