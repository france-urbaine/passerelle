# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::UpdateService do
  subject(:service) do
    described_class
  end

  let!(:report) { create(:report, :creation_local_habitation, :low_priority) }
  let!(:attributes) do
    {
      anomalies: ["omission_batie"],
      date_constat: Time.current,
      situation_proprietaire: "Doe",
      situation_numero_ordre_proprietaire: "A12345",
      situation_parcelle: "AA 0000",
      situation_numero_voie: "1",
      situation_libelle_voie: "rue de la Liberté",
      situation_code_rivoli: "0000",
      proposition_nature: "AP",
      proposition_categorie: "1",
      proposition_surface_reelle: "70",
      proposition_date_achevement: "2023-01-01"
    }
  end
  let!(:incomplete_attributes) do
    {
      anomalies: ["omission_batie"],
      date_constat: Time.current,
      situation_parcelle: nil
    }
  end

  context "when report is incomplete and updated with complete form" do
    it "marks report as complete" do
      expect { service.new(report, attributes).save }.to change(report, :completed_at).from(nil)
    end
  end

  context "when report is incomplete and updated with incomplete form" do
    it "doesn't mark report as complete" do
      expect { service.new(report, incomplete_attributes).save }.not_to change(report, :completed_at).from(nil)
    end
  end

  context "when report is complete and updated with incomplete form" do
    before { service.new(report, attributes).save }

    it "marks report as incomplete" do
      expect { service.new(report, incomplete_attributes).save }.to change(report, :completed_at).to(nil)
    end
  end
end
