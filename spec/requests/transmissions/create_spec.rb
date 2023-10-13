# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#create" do
  subject(:request) do
    post "/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:collectivity) { create(:collectivity) }
  let!(:reports) do
    [
      create(:report, collectivity:),
      create(:report, :completed, collectivity:),
      create(:report, :completed, collectivity:),
      create(:report, :transmitted, collectivity:)
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
      before { sign_in_as(organization: collectivity) }

      context "when adding a transmissible report" do
        let(:ids) { [reports[1].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(Transmission, :count).by(1) }

        it "assigns expected attributes to the new user's transmission" do
          request
          expect(Transmission.last).to have_attributes(
            collectivity_id:  collectivity.id,
            user_id:          current_user.id
          )
        end

        it "add report to new user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change { current_user.active_transmission&.reports&.count }.from(nil).to(1)
        end
      end

      context "when adding a transmissible report to an active transmission" do
        let!(:transmission) { current_user.transmissions.create(collectivity:) }
        let(:ids) { [reports[1].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.not_to change(Transmission, :count) }

        it "add report to new user's transmission" do
          expect {
            request
            transmission.reload
          }.to change(transmission.reports, :count).from(0).to(1)
        end
      end

      context "when adding an incomplete report" do
        let(:ids) { [reports[0].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(Transmission, :count).by(1) }

        it "doesn't add report to new user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change { current_user.active_transmission&.reports&.count }.from(nil).to(0)
        end
      end

      context "when adding a transmitted report" do
        let(:ids) { [reports[3].id] }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(Transmission, :count).by(1) }

        it "doesn't add report to new user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
          }.to change { current_user.active_transmission&.reports&.count }.from(nil).to(0)
        end
      end

      context "when adding multiple reports" do
        let(:ids) { reports.map(&:id) }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(Transmission, :count).by(1) }

        it "only adds transmissibles reports to user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
            reports.each(&:reload)
          }.to change { current_user.active_transmission&.reports&.count }.from(nil).to(2)
            .and not_change(reports[0], :transmission_id).from(nil)
            .and change(reports[1], :transmission_id).to(be_present)
            .and change(reports[2], :transmission_id).to(be_present)
            .and not_change(reports[3], :transmission_id).from(be_present)
        end
      end

      context "when adding all available reports" do
        let(:ids) { "all" }

        it { expect(response).to have_http_status(:success) }
        it { expect { request }.to change(Transmission, :count).by(1) }

        it "only adds transmissibles reports to user's transmission" do
          expect {
            request
            current_user.reload_active_transmission
            reports.each(&:reload)
          }.to change { current_user.active_transmission&.reports&.count }.from(nil).to(2)
            .and not_change(reports[0], :transmission_id).from(nil)
            .and change(reports[1], :transmission_id).to(be_present)
            .and change(reports[2], :transmission_id).to(be_present)
            .and not_change(reports[3], :transmission_id).from(be_present)
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
        it { expect(response.body).to not_include("target=\"status_report_#{reports[3].id}\"") }
        it { expect(response.body).to not_include("target=\"transmission_button_report_#{reports[0].id}\"") }
        it { expect(response.body).to include("target=\"transmission_button_report_#{reports[1].id}\"") }
        it { expect(response.body).to include("target=\"transmission_button_report_#{reports[2].id}\"") }
        it { expect(response.body).to not_include("target=\"transmission_button_report_#{reports[3].id}\"") }
        it { expect(response.body).to include("target=\"modal\"") }
      end
    end
  end
end
