# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#index" do
  subject(:request) { get "/utilisateurs", headers: }

  let(:headers) { {} }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  context "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end

  context "when requesting HTML and filtering collection" do
    context "with proper parameters" do
      let(:params) { { search: "C*", page: 2, items: 5 } }

      it { expect(response).to have_http_status(:success) }
    end

    context "with overflowing pages" do
      let(:params) { { page: 999_999 } }

      it { expect(response).to have_http_status(:success) }
    end

    context "with unknown order parameter" do
      let(:params) { { order: "dgfqjhsdf" } }

      it { expect(response).to have_http_status(:success) }
    end
  end
end
