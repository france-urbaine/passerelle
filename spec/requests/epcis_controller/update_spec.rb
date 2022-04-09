# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EpcisController#update", type: :request do
  subject(:request) { patch "/epcis/#{epci.id}", headers:, params: }

  let(:epci)    { create(:epci, name: "CA d'Agen") }
  let(:params)  { { epci: { name: "Agglomération d'Agen" } } }
  let(:headers) { {} }

  context "when requesting HTML with valid parameters" do
    before { request }

    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/epcis/#{epci.id}") }

    it "updates the requested epci" do
      epci.reload
      expect(epci).to have_attributes(name: "Agglomération d'Agen")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { epci: { name: "" } } }

    before { request }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "didn't update the requested epci" do
      expect{ epci.reload }.not_to change(epci, :updated_at)
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
