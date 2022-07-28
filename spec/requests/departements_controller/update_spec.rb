# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DepartementsController#update", type: :request do
  subject(:request) { patch "/departements/#{departement.id}", headers:, params: }

  let(:headers)     { {} }
  let(:params)      { { departement: { name: "Vendée" } } }
  let(:departement) { create(:departement, name: "VendÉe") }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/departements") }

    it "is expected to update the record" do
      expect {
        request
        departement.reload
      } .to  change(departement, :updated_at)
        .and change(departement, :name).to("Vendée")
    end

    context "with invalid parameters" do
      let(:params) { { departement: { name: "" } } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not update the record" do
        expect {
          request
          departement.reload
        } .to  maintain(departement, :updated_at)
          .and maintain(departement, :name)
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
        departement.reload
      } .to  maintain(departement, :updated_at)
        .and maintain(departement, :name)
    end
  end
end
