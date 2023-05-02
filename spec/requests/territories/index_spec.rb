# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TerritoriesController#index" do
  subject(:request) do
    get "/territoires", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  before do
    create_list(:commune, 2)
    create_list(:epci, 2)
    create_list(:departement, 2)
    create_list(:region, 2)
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    context "with autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      let(:params) { { q: "" } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_partial_html.to match(%r{\A<li.*</li>\Z}) }
    end
  end

  context "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
