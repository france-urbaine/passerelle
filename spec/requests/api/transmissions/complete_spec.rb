# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::TransmissionsController#complete", :api do
  subject(:request) do
    put "/transmissions/#{transmission.id}/complete", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).reverse_merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  let(:transmission) { create(:transmission, :made_through_api, :with_reports) }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    context "when the transmission is owned by the current publisher" do
      let(:transmission) { create(:transmission, :made_through_api, :with_reports, publisher: current_publisher) }

      it_behaves_like "it allows access when authorized through OAuth"
    end
  end

  describe "responses" do
    before { setup_access_token(transmission.publisher) }

    context "when transmission is still active" do
      it { expect(response).to have_http_status(:success) }
      it { expect { request }.to change(Package, :count).by(1) }

      it "completes the transmission" do
        expect {
          request
          transmission.reload
        }.to change(transmission, :completed_at).from(nil).to(be_present)
      end

      it "returns the transmitted packages & reports" do
        request

        transmission.reload
        package = transmission.packages.last
        report  = package.reports.last

        expect(response.parsed_body).to include(
          "id"           => transmission.id,
          "completed_at" => be_present.and(eq(transmission.completed_at.iso8601(3))),
          "packages"     => [
            {
              "id" => package.id,
              "name" => package.name,
              "reference" => package.reference,
              "reports" => [
                {
                  "id" => report.id,
                  "reference" => report.reference
                }
              ]
            }
          ]
        )
      end
    end

    context "when transmission is already completed" do
      let(:transmission) { create(:transmission, :made_through_api, :with_reports, :completed) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error" => "Cette transmission est déjà complétée.")
      end
    end

    context "without reports" do
      let(:transmission) { create(:transmission, :made_through_api) }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error" => "Aucun signalement présent dans cette transmision.")
      end
    end

    context "with incomplete reports" do
      before { transmission.reports.update_all(completed_at: nil) }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error" => "Certains signalements ne sont pas complets.")
      end
    end
  end
end