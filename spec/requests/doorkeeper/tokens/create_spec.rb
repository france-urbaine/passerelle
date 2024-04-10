# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Doorkeeper::TokensController#create", :api_request do
  subject(:request) do
    post "/oauth/token", as: :json, headers:, params:, xhr:
  end

  let(:params) do |e|
    e.metadata.fetch(:params, {
      "grant_type"    => "client_credentials",
      "client_id"     => test_app.uid,
      "client_secret" => test_app.secret
    })
  end

  let(:headers) { |e| e.metadata[:headers] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:test_app) { create(:oauth_application) }

  context "when using client_credentials flow" do
    context "with a valid application" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:json) }
    end

    context "with invalid params", params: { "grant_type" => "client_credentials", "client_id" => "invalid_client_id", "client_secret" => "invalid_client_secret" } do
      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(response).to have_media_type(:json) }
    end

    context "with a discarded application" do
      before { test_app.discard! }

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(response).to have_media_type(:json) }
    end
  end
end
