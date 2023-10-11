# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Reports::AttachmentsController#destroy", :api do
  subject(:request) do
    delete "/signalements/#{report.id}/documents/#{document.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  let!(:publisher) { create(:publisher) }
  let!(:report) { create(:report, publisher: publisher) }
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

    context "when current publisher is the owner of the report" do
      before { setup_access_token(publisher) }

      it "respond with success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "responses" do
    before do
      setup_access_token(publisher)
      report.documents.attach(
        io:       file_fixture("sample.pdf").open,
        filename: "present.pdf"
      )
    end

    context "with valid parameters" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(report.documents, :count).by(-1) }
      it { expect(response).not_to have_json_body }
    end

    context "when report has package" do
      let(:report) { create(:report, publisher: publisher, package: build(:package)) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(report.documents, :count) }

      it "responds with the report unauthorized error" do
        expect(response).to have_json_body.to include(
          "error" => "Vous ne disposez pas des permissions suffisantes pour accéder à cette resource."
        )
      end
    end
  end
end
