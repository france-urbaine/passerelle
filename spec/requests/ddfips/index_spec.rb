# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#index" do
  subject(:request) do
    get "/ddfips", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  before { create_list(:ddfip, 3) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    context "with autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      let(:params) { { q: DDFIP.first.name } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_partial_html.to match(%r{\A<li.*</li>\Z}) }
    end

    context "with parameters to filter ddfips", params: { search: "C", order: "-siren", page: 2, items: 5 } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with overflowing pages", params: { page: 999_999 } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end

    context "with unknown order parameter", params: { order: "unknown" } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
    end
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
