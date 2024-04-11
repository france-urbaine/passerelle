# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#show" do
  subject(:request) do
    get "/signalements/#{report.id}", as:, headers:, params:
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

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when report has been created through API for current user collectivity" do
      let(:report) { create(:report, :made_through_api, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been transmitted through API for current user collectivity" do
      let(:report) { create(:report, :transmitted_through_api, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when report has been created by current user publisher" do
      let(:report) { create(:report, :made_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when report has been transmitted by current user publisher" do
      let(:report) { create(:report, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when report has been transmitted to current user DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user"
    end

    context "when report has been assigned to current user office" do
      let(:ddfip)  { current_user.organization }
      let(:office) { create(:office, ddfip:, users: [current_user]) }
      let(:report) { create(:report, :assigned_to_office, ddfip:, office:) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to DDFIP user"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      let!(:report) { create(:report, :made_through_web_ui) }

      before { sign_in_as(organization: report.collectivity) }

      context "when the report is packing" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the report is transmitted" do
        let(:report) { create(:report, :transmitted_through_web_ui) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the report is discarded" do
        let(:report) { create(:report, :made_through_web_ui, :discarded) }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce signalement est en cours de suppression.") }
      end

      context "when the report is missing" do
        before { report.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce signalement n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when signed in as a ddfip admin" do
      let!(:report) { create(:report, :transmitted_to_ddfip) }

      before { sign_in_as(:organization_admin, organization: report.ddfip) }

      context "when the report is open for first time" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "acknowledge the report" do
          expect { request and report.reload }
            .to  change(report, :state).from("transmitted").to("acknowledged")
            .and change(report, :acknowledged_at).to be_present
        end
      end
    end
  end
end
