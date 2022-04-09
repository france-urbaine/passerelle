# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegionsController#update", type: :request do
  subject(:request) { patch "/regions/#{region.id}", headers:, params: }

  let(:region)  { create(:region, name: "Ile de France") }
  let(:params)  { { region: { name: "Ile-de-France" } } }
  let(:headers) { {} }

  context "when requesting HTML with valid parameters" do
    before { request }

    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/regions/#{region.id}") }

    it "updates the requested region" do
      region.reload
      expect(region).to have_attributes(name: "Ile-de-France")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { region: { name: "" } } }

    before { request }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "didn't update the requested region" do
      expect{ region.reload }.not_to change(region, :updated_at)
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
