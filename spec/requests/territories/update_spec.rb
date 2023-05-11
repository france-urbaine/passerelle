# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TerritoriesController#update" do
  subject(:request) { patch "/territoires", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { territories_update: { communes_url: url, epcis_url: url } } }
  let(:url)     { "https://www.insee.fr/valid/path/to/file.zip" }

  before do
    stub_request(:head, "https://www.insee.fr/valid/path/to/file.zip")
      .to_return(status: 200, body: "", headers: {})
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/communes") }

    it "is expected to enqueue jobs" do
      expect {
        request
      } .to  have_enqueued_job(ImportCommunesJob).with(url)
        .and have_enqueued_job(ImportEPCIsJob).with(url)
    end

    context "with invalid attributes" do
      let(:params) { { region: { name: "" } } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "is expected to not enqueue any jobs" do
        expect { request }.not_to have_enqueued_job
      end
    end
  end

  context "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not enqueue any jobs" do
      expect { request }.not_to have_enqueued_job
    end
  end
end
