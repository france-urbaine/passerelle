# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::AssignmentsController#destroy" do
  subject(:request) do
    delete "/signalements/#{report.id}/assign", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip)  { create(:ddfip) }
  let!(:report) { create(:report, ddfip:) }
  let!(:office) { create(:office, ddfip:) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"

    context "when report is transmitted" do
      let(:report) { create(:report, :transmitted) }

      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is assigned" do
      let(:report) { create(:report, :assigned) }

      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is transmitted in sandbox" do
      let(:report) { create(:report, :transmitted, :sandbox) }

      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when discarded report is transmitted" do
      let(:report) { create(:report, :transmitted, :discarded) }

      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is ready" do
      let(:report) { create(:report, :ready) }

      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is approved" do
      let(:report) { create(:report, :approved) }

      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is rejected" do
      let(:report) { create(:report, :rejected) }

      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is denied" do
      let(:report) { create(:report, :denied) }

      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    context "when signed in as a DDFIP admin" do
      before { sign_in_as(organization: ddfip, organization_admin: true) }

      context "with assigned report" do
        let(:report) { create(:report, :assigned, ddfip:, office:) }

        it { expect(response).to have_http_status(:see_other) }

        it "change state" do
          expect {
            request
            report.reload
          }.to change(report, :state).from("processing").to("acknowledged")
            .and not_change(report, :assigned_at)
            .and change(report, :acknowledged_at)
        end
      end
    end
  end
end
