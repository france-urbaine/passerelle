# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::CollectivitiesController#index" do
  subject(:request) do
    get "/api/collectivites", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }
  let(:collectivity) { create(:collectivity) }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"
    it_behaves_like "it allows access when authorized through OAuth"
  end

  describe "responses" do
    before { setup_access_token(collectivity.publisher) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_json_body.to include("collectivites"=>[hash_including("id"=>collectivity.id)]) }
  end
end
