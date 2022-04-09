# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegionsController#edit", type: :request do
  subject(:request) { get "/regions/#{region.id}/edit", headers: }

  let(:region)  { create(:region) }
  let(:headers) { {} }

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
end
