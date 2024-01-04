# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::DocumentsController#show" do
  subject(:request) do
    get "/signalements/#{report.id}/documents/#{document.id}/sample.pdf", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report) }
  let!(:document) do
    report.documents.attach(io: file_fixture("sample.pdf").open, filename: "sample.pdf")
    report.documents.last
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"

    # Testing other format is irrelevant because format is forced to be HTML.
    #
    # it_behaves_like "it requires to be signed in in JSON"
    # it_behaves_like "it responds with not acceptable in JSON when signed in"

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
    before { sign_in_as(organization: collectivity) }

    let(:collectivity) { create(:collectivity) }
    let(:report)       { create(:report, :made_through_web_ui, collectivity: collectivity) }
    let(:package)      { create(:package, :transmitted_through_web_ui, collectivity: collectivity, reports: [report]) }

    context "when the report is accessible" do
      it { expect(response).to have_http_status(:found) }
      it { expect(response).to redirect_to(%r{http://example.com/rails/active_storage/disk/.{362}/sample.pdf}) }
    end

    context "when the report is transmitted" do
      before { report.transmit! }

      it { expect(response).to have_http_status(:found) }
      it { expect(response).to redirect_to(%r{http://example.com/rails/active_storage/disk/.{362}/sample.pdf}) }
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
