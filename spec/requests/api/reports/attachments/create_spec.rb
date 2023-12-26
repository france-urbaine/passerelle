# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Reports::AttachmentsController#create", :api do
  subject(:request) do
    post "/signalements/#{report.id}/documents", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params) do |e|
    e.metadata.fetch(:params, {
      file: {
        filename: "sample.pdf",
        byte_size: 3_849,
        checksum: "keKnRxGllrNnMpX19UouVQ",
        content_type: "application/pdf"
      }
    })
  end

  let!(:report) { create(:report, :made_through_api) }

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
      it "creates a new blob" do
        expect { request }.to change(ActiveStorage::Blob, :count).by(1)
      end

      it "responds with success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "returns the ID of the attachment", :show_in_doc do
        request
        expect(response).to have_json_body.to include(
          "document" => {
            "id" => ActiveStorage::Attachment.order(created_at: :desc).first.id
          },
          "direct_upload" => {
            "url" => %r{^http://api\.example\.com/rails/active_storage/disk/[a-zA-Z0-9-=]{342}$},
            "headers" => {
              "Content-Type" => "application/pdf"
            }
          }
        )
      end

      it { expect { request }.to change(report.documents, :count).by(1) }

      it "assigns expected attributes to the new record", :show_in_doc do
        request
        expect(report.documents.last.filename).to eq("sample.pdf")
      end
    end

    context "when report has other attachements" do
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

      it "returns the signed ID of the blob", :show_in_doc do
        request
        expect(response).to have_json_body.to include(
          "document" => {
            "id" => ActiveStorage::Attachment.order(created_at: :desc).first.id
          },
          "direct_upload" => {
            "url" => %r{^http://api\.example\.com/rails/active_storage/disk/[a-zA-Z0-9-=]{342}$},
            "headers" => {
              "Content-Type" => "application/pdf"
            }
          }
        )
      end

      it { expect { request }.to change(report.documents, :count).from(2).to(3) }
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
