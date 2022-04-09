# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EpcisController#index", type: :request do
  subject(:request) { get "/epcis", headers:, params: }

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
      let(:params) { { search: "64", order: "-epci", page: 2, items: 5 } }

      before do
        departement = create(:departement, code_departement: "64")
        create_list(:epci, 7, departement:)
        create_list(:epci, 3)

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
