# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DepartementsController#update", type: :request do
  subject(:request) { patch "/departements/#{departement.id}", headers:, params: }

  let(:departement) { create(:departement, name: "VendÉe") }
  let(:params)  { { departement: { name: "Vendée" } } }
  let(:headers) { {} }

  context "when requesting HTML with valid parameters" do
    before { request }

    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/departements") }

    it "updates the requested departement" do
      departement.reload
      expect(departement).to have_attributes(name: "Vendée")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { departement: { name: "" } } }

    before { request }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "didn't update the requested departement" do
      expect{ departement.reload }.not_to change(departement, :updated_at)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    before { request }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
