# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegionsController#update" do
  subject(:request) { patch "/regions/#{region.id}", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { region: { name: "Ile-de-France" } } }
  let(:region)  { create(:region, name: "Ile de France") }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/regions") }

    it "is expected to update the record" do
      expect {
        request
        region.reload
      } .to  change(region, :updated_at)
        .and change(region, :name).to("Ile-de-France")
    end

    context "with invalid parameters" do
      let(:params) { { region: { name: "" } } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not update the record" do
        expect {
          request
          region.reload
        } .to  maintain(region, :updated_at)
          .and maintain(region, :name)
      end
    end
  end

  describe "rejected request as JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not update the record" do
      expect {
        request
        region.reload
      } .to  maintain(region, :updated_at)
        .and maintain(region, :name)
    end
  end
end
