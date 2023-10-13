# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Reports::AttachmentsController#destroy", :api do
  subject(:request) do
    delete "/signalements/#{report.id}/documents/#{document.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  let!(:report) { create(:report, :made_through_api) }

  let!(:document) do
    report.documents.attach(
      io:       file_fixture("sample.pdf").open,
      filename: "sample.pdf"
    )
    report.documents.last
  end

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"
    it_behaves_like "it denies access when authorized through OAuth"

    context "when report has been sent by current publisher" do
      let(:report) { create(:report, :made_through_api, publisher: current_publisher) }

      it_behaves_like "it allows access when authorized through OAuth"
    end

    context "when report has been created by a collectivity owned by current publisher" do
      let(:report) { create(:report, :made_through_web_ui, collectivity_publisher: current_publisher) }

      it_behaves_like "it denies access when authorized through OAuth"
    end
  end

  describe "responses" do
    before { setup_access_token(report.publisher) }

    context "with valid parameters" do
      it { expect(response).to have_http_status(:no_content) }
      it { expect { request }.to change(report.documents, :count).by(-1) }
    end

    context "when report is already transmitted" do
      let(:report) { create(:report, :transmitted_through_api) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(report.documents, :count) }

      it "returns a specific error message" do
        expect(response).to have_json_body.to eq(
          "error" => "Ce signalement est déjà transmis et ne peux plus être modifié."
        )
      end
    end
  end
end
