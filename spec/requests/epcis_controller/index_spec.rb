# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EpcisController#index" do
  subject(:request) { get "/epcis", headers:, params: }

  let(:headers) { {} }
  let(:params)  { {} }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    context "when filtering with multiple parameters" do
      let(:params) { { search: "C*", order: "-departement", page: 2, items: 5 } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with overflowing pages" do
      let(:params) { { page: 999_999 } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with unknown order parameter" do
      let(:params) { { order: "dgfqjhsdf" } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with autocompletion" do
      let(:headers) { { "Accept-Variant" => "autocomplete" } }
      let(:params)  { { q: "C" } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end
  end

  context "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
