# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::ReportsController#create", :api do
  subject(:request) do
    post "/transmissions/#{transmission.id}/signalements", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }

  let!(:transmission) { create(:transmission, :made_through_api) }

  let(:attributes) do
    {
      form_type: "creation_local_habitation",
      anomalies: ["omission_batie"],
      priority: "low",
      code_insee: "64019",
      date_constat: "2023-01-02",
      situation_proprietaire: "Doe",
      situation_numero_ordre_proprietaire: "A12345",
      situation_parcelle: "AA 0000",
      situation_numero_voie: "1",
      situation_libelle_voie: "rue de la Liberté",
      situation_code_rivoli: "0000",
      proposition_nature: "AP",
      proposition_categorie: "1",
      proposition_surface_reelle: 70.0,
      proposition_date_achevement: "2023-01-01"
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    context "when the transmission is owned by the current publisher" do
      let(:transmission) { create(:transmission, :made_through_api, :with_reports, publisher: current_publisher) }

      it_behaves_like "it allows access when authorized through OAuth"
    end
  end

  describe "responses" do
    before { setup_access_token(transmission.publisher) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(Report, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Report.last).to have_attributes(
          collectivity_id:                     transmission.collectivity_id,
          publisher_id:                        transmission.publisher.id,
          transmission_id:                     transmission.id,
          date_constat:                        be_a(Date),
          situation_numero_ordre_proprietaire: "A12345",
          situation_parcelle:                  "AA 0000"
        )
      end

      it "returns the new report ID", :show_in_doc do
        request
        expect(response).to have_json_body.to eq(
          "report" => {
            "id" => Report.last.id
          }
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) do
        super().merge(
          date_constat: nil,
          code_insee:   "invalid"
        )
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.not_to change(Report, :count) }

      it "responds with validations errors", :show_in_doc do
        expect(response).to have_json_body.to include(
          "errors" => hash_including(
            "date_constat" => ["Ce champs est requis"],
            "code_insee"   => ["n'est pas valide"]
          )
        )
      end
    end

    context "when transmission is already completed" do
      let(:transmission) { create(:transmission, :made_through_api, :with_reports, :completed) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body.to include(
          "error" => "Cette transmission est déjà complétée."
        )
      end
    end
  end
end
