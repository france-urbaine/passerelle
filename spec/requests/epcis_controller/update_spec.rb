# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EpcisController#update" do
  subject(:request) { patch "/epcis/#{epci.id}", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { epci: { name: "Agglomération d'Agen" } } }
  let(:epci)    { create(:epci, name: "CA d'Agen") }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/epcis") }

    it "is expected to update the record" do
      expect {
        request
        epci.reload
      } .to  change(epci, :updated_at)
        .and change(epci, :name).to("Agglomération d'Agen")
    end

    context "with invalid parameters" do
      let(:params) { { epci: { name: "" } } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not update the record" do
        expect {
          request
          epci.reload
        } .to  maintain(epci, :updated_at)
          .and maintain(epci, :name)
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
        epci.reload
      } .to  maintain(epci, :updated_at)
        .and maintain(epci, :name)
    end
  end
end
