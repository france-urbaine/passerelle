# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::ReportsController#create" do
  subject(:request) do
    post "/api/transmissions/#{transmission.id}/signalements", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }
  let!(:transmission) { create(:transmission, :made_through_api) }
  # let!(:attributes) { attributes_for(:report) }
  let(:report) { create(:report, transmission: transmission) }
  let(:update_service) { instance_double(API::Reports::UpdateService, save: true, report: report) }
  let!(:attributes) do
    {
      form_type: "evaluation_local_habitation",
      anomalies: ["affectation"],
      priority: "low",
      code_insee: "64019",
      date_constat: "2023-09-07",
      situation_annee_majic: "2022",
      situation_invariant: "4950328609",
      situation_proprietaire: "BIDART Pierre",
      situation_numero_ordre_proprietaire: "B0019601",
      situation_parcelle: "AN0159",
      situation_numero_voie: "2",
      situation_libelle_voie: "Irulegiko bidea",
      situation_code_rivoli: "0367",
      situation_numero_batiment: "A",
      situation_numero_escalier: "01",
      situation_numero_niveau: "00",
      situation_numero_porte: "01",
      situation_numero_ordre_porte: "001",
      situation_nature: "MA",
      situation_affectation: "H",
      situation_categorie: "3",
      situation_surface_reelle: "134.0",
      situation_date_mutation: "2023-09-04",
      situation_coefficient_entretien: "1.10",
      situation_coefficient_situation_generale: "0.00",
      situation_coefficient_situation_particuliere: "-0.05",
      proposition_nature: "LC",
      proposition_affectation: "B",
      proposition_categorie: "MAG6",
      proposition_surface_reelle: "155.0",
      proposition_surface_p1: "34.0",
      proposition_surface_p2: "67.0",
      proposition_coefficient_localisation: "16"
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    it_behaves_like "it allows access when authorized through OAuth" do
      let(:current_publisher) { transmission.publisher }
    end
  end

  describe "responses" do
    before do
      setup_access_token(transmission.publisher)
    end

    context "with valid report parameters and valid completeness" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(Report, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Report.last).to have_attributes(
          collectivity_id: transmission.collectivity_id,
          publisher_id:    transmission.publisher.id,
          transmission_id: transmission.id
        )
      end

      it "returns the new report ID" do
        request
        expect(response).to have_json_body.to eq("id" => Report.last.id)
      end
    end

    context "with invalid report parameters" do
      before do
        attributes[:code_insee] = "invalid"
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.not_to change(Report, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body.to include("errors" => { "code_insee" => ["n'est pas valide"] })
      end
    end

    context "with invalid report completeness" do
      before do
        attributes[:situation_annee_majic] = nil
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.not_to change(Report, :count) }

      it "responds with completeness errors" do
        expect(response).to have_json_body.to include("errors" => { "situation_annee_majic" => ["Ce champs est requis"] })
      end
    end
  end
end
