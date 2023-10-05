# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::TransmissionsController#complete" do
  subject(:request) do
    put "/api/transmissions/#{transmission.id}/complete", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }
  let!(:transmission) { create(:transmission, :made_through_api, :with_reports) }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    context "when the transmission is owned by the current publisher" do
      it_behaves_like "it allows access when authorized through OAuth" do
        let(:current_publisher) { transmission.publisher }
      end
    end
  end

  describe "responses" do
    before { setup_access_token(transmission.publisher) }

    it { expect(response).to have_http_status(:success) }
    it { expect { request }.to change(Package, :count).by(1) }

    it "completes the transmission" do
      request
      expect(Transmission.last.completed_at).not_to be_nil
    end

    it "returns the transmitted packages & reports" do
      request
      package = Transmission.last.packages.last
      report = package.reports.last
      expect(response.parsed_body).to include("id" => Transmission.last.id,
        "completed_at" => Transmission.last.completed_at.iso8601(3),
        "packages" => [
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
        ])
    end

    context "with transmission already completed" do
      before { transmission.update(completed_at: Time.current) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error"=>"Vous ne disposez pas des permissions suffisantes pour accéder à cette resource.")
      end
    end

    context "without reports" do
      before { transmission.reports.each(&:destroy) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error" => "Vous ne disposez pas des permissions suffisantes pour accéder à cette resource.")
      end
    end

    context "with incomplete reports" do
      before { transmission.reports.update_all(completed_at: nil) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response.parsed_body).to eq("error" => "Vous ne disposez pas des permissions suffisantes pour accéder à cette resource.")
      end
    end
  end
end
