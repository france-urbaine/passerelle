# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#update", type: :request do
  subject(:request) { patch "/collectivites/#{collectivity.id}", headers:, params: }

  let(:headers)      { {} }
  let(:params)       { { collectivity: { name: "CA du Pays Basque" } } }
  let(:collectivity) { create(:collectivity, name: "Agglomération Pays Basque") }

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/collectivites") }

    it "is expected to update the record" do
      expect {
        request
        collectivity.reload
      } .to  change(collectivity, :updated_at)
        .and change(collectivity, :name).to("CA du Pays Basque")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { collectivity: { name: "" } } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not update the record" do
      expect {
        request
        collectivity.reload
      } .to  maintain(collectivity, :updated_at)
        .and maintain(collectivity, :name)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not update the record" do
      expect {
        request
        collectivity.reload
      } .to  maintain(collectivity, :updated_at)
        .and maintain(collectivity, :name)
    end
  end
end
