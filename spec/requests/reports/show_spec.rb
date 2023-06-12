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
      let(:report) { create(:report, :reported_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when report has been created by current user publisher" do
      let(:report) { create(:report, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when report has been transmitted to current user DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has been approved and forwarded to current user office" do
      let(:report) { create(:report, :package_approved_by_ddfip, ddfip: current_user.organization) }

      before do
        create(:office,
          ddfip:       current_user.organization,
          competences: [report.form_type],
          communes:    [report.commune],
          users:       [current_user])
      end

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, :reported_through_web_ui, collectivity: collectivity) }

      before { sign_in_as(organization: collectivity) }

      context "when the report is active" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the report is transmitted" do
        before { report.package.touch(:transmitted_at) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the report is discarded" do
        before { report.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the report is missing" do
        before { report.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end
  end
end
