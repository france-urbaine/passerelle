# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::AssignmentsController#update" do
  subject(:request) do
    patch "/signalements/#{report.id}/assignment", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }

  let(:attributes) { { office_id: office.id } }

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

      context "with transmitted report" do
        let(:report) { create(:report, :transmitted, ddfip: ddfip) }

        it { expect(response).to have_http_status(:see_other) }

        it "assign office, change report state and fill assigned_at" do
          request

          expect(report.reload.office_id).to eq(office.id)
          expect(report.state).to eq("processing")
          expect(report.assigned_at).to be_present
        end
      end

      context "with assigned report" do
        let(:current_office) { create(:office, ddfip:) }
        let(:report) { create(:report, :assigned, ddfip:, office: current_office) }

        it { expect(response).to have_http_status(:see_other) }

        it "change office, keep report state and keep assigned_at" do
          expect {
            request
            report.reload
          }.to change(report, :office_id).from(current_office.id).to(office.id)
            .and not_change(report, :assigned_at)
            .and not_change(report, :state)
        end
      end
    end
  end
end
