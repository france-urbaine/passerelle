# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::TransmissionController#create", :api do
  subject(:request) do
    post "/collectivites/#{collectivity.id}/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).reverse_merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, { transmission: attributes }) }

  let!(:collectivity) { create(:collectivity) }

  let(:attributes) do
    { sandbox: false }
  end

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    context "when the collectivity is owned by the current publisher" do
      let(:collectivity) { create(:collectivity, publisher: current_publisher) }

      it_behaves_like "it allows access when authorized through OAuth"
    end
  end

  describe "responses" do
    before { setup_access_token(collectivity.publisher) }

    it { expect(response).to have_http_status(:success) }
    it { expect { request }.to change(Transmission, :count).by(1) }

    it "assigns expected attributes to the new record" do
      request
      expect(Transmission.last).to have_attributes(
        collectivity_id:      collectivity.id,
        oauth_application_id: current_application.id,
        publisher_id:         current_publisher.id,
        sandbox:              attributes[:sandbox]
      )
    end

    it "returns the new transmission ID" do
      expect(response.parsed_body).to eq(
        "id" => Transmission.last.id
      )
    end
  end
end
