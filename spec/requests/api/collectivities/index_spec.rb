# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::CollectivitiesController#index" do
  subject(:request) do
    get "/collectivites", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"
    it_behaves_like "it allows access when authorized through OAuth"
  end

  describe "responses" do
    before { setup_access_token }

    context "when publisher have collectivities" do
      let!(:collectivities) { create_list(:collectivity, 2, :epci, publisher: current_publisher) }

      it { expect(response).to have_http_status(:success) }

      it "returns a list of collectivities", :show_in_doc do
        expect(response).to have_json_body.to include(
          "collectivites" => be_an(Array).and(have(2).items).and(include(
            {
              "id"    => collectivities[0].id,
              "name"  => collectivities[0].name,
              "siren" => collectivities[0].siren
            }
          ))
        )
      end
    end

    context "when publisher has no collectivities" do
      it { expect(response).to have_http_status(:success) }

      it "returns a empty list of collectivities" do
        expect(response).to have_json_body.to eq(
          "collectivites" => []
        )
      end
    end
  end
end
