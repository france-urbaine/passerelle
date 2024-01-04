# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#update" do
  subject(:request) do
    delete "/signalements/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    context "when report has been created by current user collectivity" do
      let(:report) { create(:report, :made_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when report has been transmitted by current user collectivity" do
      let(:report) { create(:report, :transmitted_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been created through API for current user collectivity" do
      let(:report) { create(:report, :made_through_api, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been transmitted through API for current user collectivity" do
      let(:report) { create(:report, :transmitted_through_api, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been created by current user publisher" do
      let(:report) { create(:report, :made_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when report has been transmitted by current user publisher" do
      let(:report) { create(:report, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when report has been transmitted to current user DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user"
    end

    context "when report has been assigned to current user office" do
      let(:ddfip)  { current_user.organization }
      let(:office) { create(:office, ddfip:, users: [current_user]) }
      let(:report) { create(:report, :assigned_to_office, ddfip:, office:) }

      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, :made_through_web_ui, collectivity: collectivity) }
      let(:package)      { create(:package, :transmitted_through_web_ui, collectivity: collectivity, reports: [report]) }

      before { sign_in_as(organization: report.collectivity) }

      context "when the report is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/signalements") }
        it { expect { request }.to change(Report.discarded, :count).by(1) }

        it "discards the report" do
          expect { request and report.reload }
            .to change(report, :discarded_at).to(be_present)
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            scheme: "success",
            header: "Le signalement a été supprimé.",
            body:   "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
            delay:    10_000
          )
        end

        it "sets a flash action to cancel" do
          expect(flash).to have_flash_actions.to include(
            label:  "Annuler",
            method: "patch",
            url:    "/signalements/#{report.id}/undiscard",
            params: {}
          )
        end
      end

      context "when the report is discarded" do
        before { report.discard }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/signalements") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
        it { expect { request }.not_to change(Report.discarded, :count).from(1) }
      end

      context "when the report is missing" do
        before { report.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/signalements") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
      end

      context "with redirect parameter", params: { redirect: "/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
      end
    end
  end
end
