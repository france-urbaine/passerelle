# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::AssignmentsController#update" do
  subject(:request) do
    patch "/signalements/assign/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip:) }
  let!(:report) { create(:report, :accepted_by_ddfip, ddfip:) }

  let(:attributes) do
    { office_id: office.id }
  end

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

    context "when report has already been accepted by the current DDFIP" do
      let(:report) { create(:report, :accepted_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has not yet been accepted to the current DDFIP" do
      let(:report) { create(:report, :acknowledged_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been assigned by the current DDFIP" do
      let(:report) { create(:report, :assigned_to_office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has already been rejected by the current DDFIP" do
      let(:report) { create(:report, :rejected_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been resolved by the current DDFIP" do
      let(:report) { create(:report, :resolved_as_applicable, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "when report is waiting for assignment" do
      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/signalements/#{report.id}") }

        it "assigns the report" do
          expect {
            request
            report.reload
          }
            .to  change(report, :updated_at)
            .and change(report, :state).to("assigned")
            .and change(report, :office_id).to(office.id)
            .and change(report, :assigned_at).to(be_present)
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            scheme: "success",
            header: "Le signalement a été assigné au guichet sélectionné.",
            delay:  3000
          )
        end
      end

      context "with missing office" do
        let(:attributes) { { office_id: nil } }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "doesn't update the report" do
          expect {
            request
            report.reload
          }.not_to change(report, :updated_at)
        end
      end

      context "when report is already assigned" do
        let!(:another_office) { create(:office, ddfip:) }
        let!(:report)         { create(:report, :assigned_by_ddfip, ddfip:, office: another_office) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/signalements/#{report.id}") }

        it "updates the assigned office" do
          expect {
            request
            report.reload
          }
            .to  change(report, :updated_at)
            .and change(report, :office_id).to(office.id)
            .and not_change(report, :state).from("assigned")
            .and not_change(report, :assigned_at)
        end
      end
    end
  end
end
