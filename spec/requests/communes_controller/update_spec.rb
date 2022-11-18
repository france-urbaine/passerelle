# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CommunesController#update" do
  subject(:request) { patch "/communes/#{commune.id}", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { commune: { name: "L'Abergement-Clémenciat" } } }
  let(:commune) { create(:commune, name: "L'AEbergement-ClÉmenciat") }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/communes") }

    it "is expected to update the record" do
      expect {
        request
        commune.reload
      } .to  change(commune, :updated_at)
        .and change(commune, :name).to("L'Abergement-Clémenciat")
    end

    context "with invalid parameters" do
      let(:params) { { commune: { name: "" } } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not update the record" do
        expect {
          request
          commune.reload
        } .to  maintain(commune, :updated_at)
          .and maintain(commune, :name)
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
        commune.reload
      } .to  maintain(commune, :updated_at)
        .and maintain(commune, :name)
    end
  end
end
