# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#update" do
  subject(:request) { patch "/editeurs/#{publisher.id}", headers:, params: }

  let(:headers)   { {} }
  let(:params)    { { publisher: { name: "DDFIP de Paris" } } }
  let(:publisher) { create(:publisher, name: "Ddfip du Paris") }

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/editeurs") }

    it "is expected to update the record" do
      expect {
        request
        publisher.reload
      } .to  change(publisher, :updated_at)
        .and change(publisher, :name).to("DDFIP de Paris")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { publisher: { name: "" } } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not update the record" do
      expect {
        request
        publisher.reload
      } .to  maintain(publisher, :updated_at)
        .and maintain(publisher, :name)
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
        publisher.reload
      } .to  maintain(publisher, :updated_at)
        .and maintain(publisher, :name)
    end
  end
end
