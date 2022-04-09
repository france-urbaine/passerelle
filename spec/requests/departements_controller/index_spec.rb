# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DepartementsController#index", type: :request do
  subject(:request) { get "/departements", headers:, params: }

  let(:headers) { {} }
  let(:params)  { {} }

  describe "successful response when requesting HTML" do
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  describe "unacceptable response when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    before { request }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end

  describe "filtering collection" do
    context "with proper parameters" do
      let(:params) { { search: "C*", order: "-departement", page: 2, items: 5 } }

      before do
        create(:departement, code_departement: "14", name: "Calvados")
        create(:departement, code_departement: "15", name: "Cantal")
        create(:departement, code_departement: "16", name: "Charente")
        create(:departement, code_departement: "17", name: "Charente-Maritime")
        create(:departement, code_departement: "18", name: "Cher")
        create(:departement, code_departement: "19", name: "Corrèze")
        create(:departement, code_departement: "21", name: "Côte-d'Or")
        request
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with overflowing pages" do
      let(:params) { { page: 999_999 } }

      before { request }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with unknown order parameter" do
      let(:params) { { order: "dgfqjhsdf" } }

      before { request }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end
  end
end
