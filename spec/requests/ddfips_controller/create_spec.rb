# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#create", type: :request do
  subject(:request) { post "/ddfips", headers:, params: }

  let(:headers)     { {} }
  let(:params)      { { ddfip: attributes } }
  let(:departement) { create(:departement) }

  let(:attributes) do
    {
      name:             departement&.name,
      code_departement: departement.code_departement
    }
  end

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/ddfips") }

    it "is expected to create a record" do
      expect { request }.to change(DDFIP, :count).by(1)
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:attributes) { { name: "", code_departement: "" } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not create any record" do
      expect { request }.to maintain(DDFIP, :count).from(0)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not create any record" do
      expect{ request }.to maintain(DDFIP, :count).from(0)
    end
  end
end
