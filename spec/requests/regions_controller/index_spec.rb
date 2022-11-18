# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegionsController#index" do
  subject(:request) { get "/regions", headers:, params: }

  let(:headers) { {} }
  let(:params)  { {} }

  describe "successful request as HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  describe "successful request to autocomplete as HTML" do
    let(:headers) { { "Accept-Variant" => "autocomplete" } }
    let(:params)  { { q: "C" } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
  end

  describe "rejected request as JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
