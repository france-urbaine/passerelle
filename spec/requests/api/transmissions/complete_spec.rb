# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::TransmissionsController#complete", :api do
  subject(:request) do
    put "/transmissions/#{transmission.id}/finalisation", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).reverse_merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  let(:transmission) { create(:transmission, :with_reports, :made_through_api, :made_for_ddfip) }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    context "when the transmission do not belongs to current application" do
      let(:transmission) { create(:transmission, :with_reports, :made_through_api, :made_for_ddfip, publisher: current_publisher) }

      it_behaves_like "it responds with not found when authorized through OAuth"
    end

    context "when the transmission belongs to the current application" do
      let(:transmission) { create(:transmission, :with_reports, :made_through_api, :made_for_ddfip, publisher: current_publisher, oauth_application: current_application) }

      it_behaves_like "it allows access when authorized through OAuth"
    end
  end

  describe "responses" do
    before { setup_access_token(transmission.publisher, transmission.oauth_application) }

    context "when transmission is still active" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(Package, :count).from(0).to(1) }

      it "completes the transmission" do
        expect {
          request
          transmission.reload
        }.to change(transmission, :completed_at).from(nil).to(be_present)
      end

      it "returns the transmitted packages & reports", :show_in_doc do
        request
        expect(response).to have_json_body.to include(
          "transmission"   => {
            "id"            => transmission.id,
            "completed_at"  => match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/),
            "packages"      => [
              {
                "id"          => match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/),
                "reference"   => match(/\d{4}-\d{2}-\d{4}/),
                "reports"       => [
                  {
                    "id"          => match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/),
                    "reference"   => match(/\d{4}-\d{2}-\d{4}-\d{5}/)
                  }
                ]
              }
            ]
          }
        )
      end
    end

    context "when transmission is already completed" do
      let(:transmission) { create(:transmission, :with_reports, :made_for_ddfip, :completed_through_api) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "returns a specific error message" do
        expect(response).to have_json_body.to eq(
          "error" => "Cette transmission est déjà complétée."
        )
      end
    end

    context "without reports" do
      let(:transmission) { create(:transmission, :made_through_api) }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect { request }.not_to change(Package, :count) }

      it "returns a specific error message" do
        expect(response).to have_json_body.to eq(
          "error" => "Aucun signalement présent dans cette transmission."
        )
      end
    end

    context "with incomplete reports" do
      let(:transmission) { create(:transmission, :with_incomplete_reports, :made_through_api) }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect { request }.not_to change(Package, :count) }

      it "returns a specific error message" do
        expect(response).to have_json_body.to eq(
          "error" => "Certains signalements ne sont pas complets."
        )
      end
    end
  end
end
