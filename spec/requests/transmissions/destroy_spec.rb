# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#destroy" do
  subject(:request) do
    delete "/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:collectivity) { create(:collectivity) }
  let!(:transmission) { create(:transmission, :made_through_web_ui, collectivity:) }
  let!(:completed_transmission) { create(:transmission, :made_through_web_ui, :completed, user: transmission.user, collectivity:) }
  let!(:reports) do
    [
      create(:report, collectivity:),
      create(:report, :completed, collectivity:, transmission:),
      create(:report, :completed, collectivity:, transmission:),
      create(:report, :completed, collectivity:, transmission:),
      create(:report, :transmitted, collectivity:, transmission: completed_transmission),
      create(:report, :transmitted, collectivity:, transmission: completed_transmission)
    ]
  end

  let!(:ids) { [] }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in transmission.user }

      context "when removing a completed report from current transmission" do
        let(:ids) { [reports[1].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(transmission.reports, :count).by(-1) }

        it "remove report from user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change { current_user.active_transmission.reports.count }.from(3).to(2)
        end
      end

      context "when removing multiple reports from current transmission" do
        let(:ids) { [reports[1].id, reports[2].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(transmission.reports, :count).by(-2) }

        it "remove reports from user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change { current_user.active_transmission.reports.count }.from(3).to(1)
        end
      end

      context "when removing reports from differents transmissions" do
        let(:ids) { [reports[1].id, reports[4].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(transmission.reports, :count).by(-1) }

        it "remove only report from user's active transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to   change(current_user.active_transmission.reports, :count).from(3).to(2)
            .and not_change(completed_transmission.reports, :count)
        end
      end

      context "when removing all available reports from current transmission" do
        let(:ids) { "all" }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(transmission.reports, :count).by(-3) }

        it "remove only reports from user's active transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change(current_user.active_transmission.reports, :count).from(3).to(0)
            .and not_change(completed_transmission.reports, :count)
        end
      end

      context "when responds with Turbo Stream format", as: :turbo_stream do
        let(:ids) { "all" }

        it { expect(response).to have_http_status(:success) }
        it { expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8") }
        it { expect(response.body).to include("target=\"button_transmission_#{current_user.active_transmission.id}\"") }
        it { expect(response.body).to not_include("target=\"status_report_#{reports[0].id}\"") }
        it { expect(response.body).to include("target=\"status_report_#{reports[1].id}\"") }
        it { expect(response.body).to include("target=\"status_report_#{reports[2].id}\"") }
        it { expect(response.body).to include("target=\"status_report_#{reports[3].id}\"") }
        it { expect(response.body).to not_include("target=\"status_report_#{reports[4].id}\"") }
        it { expect(response.body).to include("target=\"modal\"") }
      end
    end
  end
end
