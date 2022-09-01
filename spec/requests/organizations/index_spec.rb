# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OrganizationsController#index", type: :request do
  subject(:request) { get "/organisations", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { q: "" } }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  context "when requesting HTML for autocompletion" do
    let(:headers) { { "Accept-Variant" => "autocomplete" } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_empty_body }

    context "with results" do
      let(:params) { { q: "Fis" } }

      before do
        create(:publisher, name: "Fiscalité & Territoire")
      end

      it { expect(response).to have_body }
    end
  end

  context "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
