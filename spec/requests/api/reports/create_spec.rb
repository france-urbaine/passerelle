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
  let!(:attributes) { attributes_for(:report) }
  let(:report) { create(:report, transmission: transmission) }
  let(:update_service) { instance_double(API::Reports::UpdateService, save: true, report: report) }

  let!(:completeness_service) { instance_double(Reports::CheckCompletenessService, valid?: true, errors: []) }

  before do
    allow(Reports::CheckCompletenessService).to receive(:new).and_return(completeness_service)
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
        allow(Reports::CheckCompletenessService).to receive(:new).and_call_original
        attributes[:code_insee] = "invalid"
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.not_to change(Report, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body.to include("errors" => { "code_insee" => ["n'est pas valide"] })
      end
    end

    context "with invalid report completeness" do
      before { allow(Reports::CheckCompletenessService).to receive(:new).and_call_original }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.not_to change(Report, :count) }

      it "responds with completeness errors" do
        expect(response).to have_json_body.to include("errors" => hash_including(
          "anomalies" => ["Ce champs est requis"],
          "code_insee" => ["Ce champs est requis"],
          "date_constat" => ["Ce champs est requis"]
        ))
      end
    end
  end
end
