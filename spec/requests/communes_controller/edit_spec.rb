# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CommunesController#edit", type: :request do
  subject(:request) { get "/communes/#{commune.id}/edit", headers: }

  let(:commune) { create(:commune) }
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