# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#create", type: :request do
  subject(:request) { post "/collectivites", headers:, params: }

  let(:headers)    { {} }
  let(:params)     { { collectivity: attributes } }
  let(:epci)       { create(:epci) }
  let(:publisher)  { create(:publisher) }

  let(:attributes) do
    {
      territory_type:     "EPCI",
      territory_id:       epci.id,
      publisher_id:       publisher.id,
      name:               epci.name,
      siren:              epci.siren,
      contact_first_name: Faker::Name.first_name,
      contact_last_name:  Faker::Name.last_name,
      contact_email:      Faker::Internet.email,
      contact_phone:      Faker::PhoneNumber.phone_number
    }
  end

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/collectivites") }

    it "is expected to create a record" do
      expect { request }.to change(Collectivity, :count).by(1)
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:attributes) { { territory_id: "" } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not create any record" do
      expect { request }.to maintain(Collectivity, :count).from(0)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not create any record" do
      expect{ request }.to maintain(Collectivity, :count).from(0)
    end
  end
end
