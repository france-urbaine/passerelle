# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CommunesController#update", type: :request do
  subject(:request) { patch "/communes/#{commune.id}", headers:, params: }

  let(:commune) { create(:commune, name: "L'AEbergement-ClÉmenciat") }
  let(:params)  { { commune: { name: "L'Abergement-Clémenciat" } } }
  let(:headers) { {} }

  context "when requesting HTML with valid parameters" do
    before { request }

    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/communes/#{commune.id}") }

    it "updates the requested commune" do
      commune.reload
      expect(commune).to have_attributes(name: "L'Abergement-Clémenciat")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { commune: { name: "" } } }

    before { request }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "didn't update the requested commune" do
      expect{ commune.reload }
        .to  maintain(commune, :updated_at)
        .and maintain(commune, :name).from("L'AEbergement-ClÉmenciat")
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
