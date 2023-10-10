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
      it_behaves_like "it allows access when authorized through OAuth" do
        let(:current_publisher) { publisher }
      end
    end
  end

  describe "responses" do
    before do
      setup_access_token(publisher)
    end

    context "with valid parameters" do
      before do
        report.documents.attach(
          io:       file_fixture("sample.pdf").open,
          filename: "present.pdf"
        )
      end
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(report.documents, :count).by(-1) }

      it "returns expected response structure" do
        request
        parsed_response = response.parsed_body

        expect(parsed_response).to have_key("id")
        expect(parsed_response["id"]).to eq(report.id)
        expect(parsed_response).to have_key("documents")
        expect(parsed_response["documents"]).to be_an(Array)

        attachment = parsed_response["documents"].first

        expect(attachment["filename"]).to eq("present.pdf")

        expect(attachment).to have_key("url")
      end
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