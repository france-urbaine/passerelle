# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::ApprovalsController#show" do
  subject(:request) do
    get "/signalements/#{report.id}/approval", as:, headers:, params:
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

    context "when report is assigned" do
      let(:report) { create(:report, :assigned) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is assigned to user organization" do
      let(:report) { create(:report, :assigned, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is approved" do
      let(:report) { create(:report, :approved, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is rejected" do
      let(:report) { create(:report, :rejected, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is transmitted" do
      let(:report) { create(:report, :transmitted, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is sandboxed" do
      let(:report) { create(:report, :assigned, :sandbox, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is discarded" do
      let(:report) { create(:report, :assigned, :discarded, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    context "when signed in as a ddfip user" do
      let(:ddfip)  { create(:ddfip) }
      let(:report) { create(:report, :assigned, ddfip:) }

      before { sign_in_as(organization: ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when signed in as a ddfip admin" do
      let(:ddfip)  { create(:ddfip) }
      let(:report) { create(:report, :assigned, ddfip: ddfip) }

      before { sign_in_as(:organization_admin, organization: ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end