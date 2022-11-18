# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#update" do
  subject(:request) { patch "/ddfips/#{ddfip.id}", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { ddfip: { name: "DDFIP des Pyrénées-Atlantiques" } } }
  let(:ddfip)   { create(:ddfip, name: "Ddfip de Pyrénée-Atlantique") }

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/ddfips") }

    it "is expected to update the record" do
      expect {
        request
        ddfip.reload
      } .to  change(ddfip, :updated_at)
        .and change(ddfip, :name).to("DDFIP des Pyrénées-Atlantiques")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { ddfip: { name: "" } } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not update the record" do
      expect {
        request
        ddfip.reload
      } .to  maintain(ddfip, :updated_at)
        .and maintain(ddfip, :name)
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
        ddfip.reload
      } .to  maintain(ddfip, :updated_at)
        .and maintain(ddfip, :name)
    end
  end
end
