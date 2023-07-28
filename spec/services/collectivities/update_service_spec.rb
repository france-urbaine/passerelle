# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivities::UpdateService do
  subject(:service) do
    described_class.new(collectivity, attributes)
  end

  let!(:collectivity) { create(:collectivity, territory: epci, name: "Agglomération Pays Basque") }
  let!(:epci)         { create(:epci) }

  let(:attributes) do
    { name: "CA du Pays Basque" }
  end

  it "returns a successful result" do
    expect(service.save).to be_successful
  end

  it "updates the collectivity's attributes" do
    expect { service.save }
      .to change(collectivity, :updated_at)
      .and change(collectivity, :name).to("CA du Pays Basque")
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

    it "doesn't update the collectivity" do
      expect { service.save }
        .not_to change(collectivity, :updated_at)
    end
  end
end
