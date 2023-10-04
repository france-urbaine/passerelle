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

  before { allow(Transmissions::CompleteService).to receive(:new).with(transmission).and_call_original }

  describe "authorizations" do
    it_behaves_like "it requires an authentication through OAuth in JSON"
    it_behaves_like "it requires an authentication through OAuth in HTML"

    it_behaves_like "it responds with not found when authorized through OAuth"

    it_behaves_like "it allows access when authorized through OAuth" do
      let(:current_publisher) { transmission.publisher }
    end
  end

  describe "responses" do
    before { setup_access_token(transmission.publisher) }

    it { expect(response).to have_http_status(:success) }
    it { expect { request }.to change(Package, :count).by(1) }

    it "assigns expected attributes to the new record" do
      request
      expect(Transmission.last.completed_at).not_to be_nil
    end

    it "returns the new transmission ID" do
      request
      expect(response).to have_json_body(id: Transmission.last.id)
        .and have_json_body(completed_at: Transmission.last.completed_at)
        .and have_json_body(packages: [instance_of(Hash)])
    end

    context "with transmission already completed" do
      before { transmission.update(completed_at: Time.current) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body(errors: instance_of(Hash))
      end
    end

    context "without nil reports" do
      before { transmission.reports.each(&:destroy) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body(errors: instance_of(Hash))
      end
    end

    context "with uncompleted reports" do
      before { transmission.reports.update_all(completed_at: nil) }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect { request }.not_to change(Package, :count) }

      it "responds with the report errors" do
        expect(response).to have_json_body(errors: instance_of(Hash))
      end
    end
  end
end
