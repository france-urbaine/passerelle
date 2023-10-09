# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Reports::CreateService do
  let(:report) { build(:report, :creation_local_habitation, :low_priority, collectivity: create(:collectivity)) }

  context "when report is created with complete form" do
    let(:attributes) do
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

    it "create a report" do
      expect { described_class.new(report, attributes).save }.to change(Report, :count).by(1)
    end

    it "assigns expected attributes to the new record" do
      described_class.new(report, attributes).save
      expect(report.situation_libelle_voie).to eq("rue de la Liberté")
    end
  end

  context "when report created with incomplete form" do
    let(:attributes) do
      {
        anomalies: ["omission_batie"],
        date_constat: Time.current,
        situation_parcelle: nil
      }
    end

    it "doesn't save the report" do
      expect { described_class.new(report, attributes).save }.not_to change(Report, :count)
    end

    it "returns errors" do
      described_class.new(report, attributes).save
      expect(report.errors).to include(
        :situation_parcelle,
        :situation_libelle_voie,
        :situation_code_rivoli,
        :situation_adresse,
        :situation_proprietaire,
        :situation_numero_ordre_proprietaire,
        :proposition_nature,
        :proposition_categorie,
        :proposition_surface_reelle,
        :proposition_surface_reelle
      )
    end
  end
end
