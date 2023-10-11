# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Reports::AttachmentsController#create", :api do
  subject(:request) do
    post "/signalements/#{report.id}/documents", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, { documents: blob.signed_id }) }

  let!(:publisher) { create(:publisher) }
  let!(:report) { create(:report, publisher: publisher) }
  let!(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io:       file_fixture("sample.pdf").open,
      filename: "sample.pdf"
    )
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
    before { setup_access_token(publisher) }

    context "with valid parameters" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(report.documents, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Report.last.documents.last.filename).to eq("sample.pdf")
      end

      it "returns expected response structure" do
        request
        parsed_response = response.parsed_body

        expect(parsed_response).to include("id" => report.id)
        expect(parsed_response["documents"].first).to include("filename" => "sample.pdf")
          .and have_key("url")
      end
    end

    context "with already attached documents" do
      before do
        report.documents.attach(ActiveStorage::Blob.create_and_upload!(
          io:       file_fixture("sample.pdf").open,
          filename: "first.pdf"
        ))
        report.documents.attach(ActiveStorage::Blob.create_and_upload!(
          io:       file_fixture("sample.pdf").open,
          filename: "second.pdf"
        ))
      end

      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(report.documents, :count).from(2).to(3) }

      it "returns expected response structure" do
        request
        parsed_response = response.parsed_body

        expect(parsed_response).to include("id" => report.id)
        expect(parsed_response["documents"].first).to include("filename" => "first.pdf")
          .and have_key("url")
        expect(parsed_response["documents"].second).to include("filename" => "second.pdf")
          .and have_key("url")
        expect(parsed_response["documents"][2]).to include("filename" => "sample.pdf")
          .and have_key("url")
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
