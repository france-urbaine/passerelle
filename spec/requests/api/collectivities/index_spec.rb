# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::CollectivitiesController#index", :api do
  subject(:request) do
    get "/collectivites", as:, headers:, params:
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
    before do
      create_list(:collectivity, 2, publisher: collectivity.publisher)
      setup_access_token(collectivity.publisher)
    end

    it { expect(response).to have_http_status(:success) }

    it "returns a list of collectivities" do
      expect(response).to have_json_body.to include(
        "collectivites" => [
          {
            "id"    => collectivity.id,
            "name"  => collectivity.name,
            "siren" => collectivity.siren
          }
        ]
      )
    end

    it "lists all collectivities", :show_in_doc do
      expect(JSON.parse(response.body)["collectivites"].length).to eq(3)
    end
  end
end
