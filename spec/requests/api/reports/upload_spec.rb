# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::UploadController#create", :api do
  subject(:request) do
    post "/upload", as: as, headers: headers, params: params
  end

  let(:as) { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { { blob: { filename: "test.png", byte_size: 123_456, checksum: "keKnRxGllrNnMpX19UouVQ", content_type: "application/pdf" } } }
  let!(:application) { create(:oauth_application) }

  describe "responses" do
    before { setup_access_token(application.owner, application) }

    context "with valid parameters" do
      it "creates a new blob" do
        expect { request }.to change(ActiveStorage::Blob, :count).by(1)
      end

      it "responds with success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "returns the signed ID of the blob", :show_in_doc do
        request
        expect(response).to have_json_body.to include(
          "signed_id" => ActiveStorage::Blob.last.signed_id
        )
      end
    end
  end
end
