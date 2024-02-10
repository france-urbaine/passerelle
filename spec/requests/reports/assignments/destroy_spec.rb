# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::AssignmentsController#destroy" do
  subject(:request) do
    delete "/signalements/assign/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report, :assigned_to_office) }

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

    context "when report has been assigned by the current DDFIP" do
      let(:report) { create(:report, :assigned_to_office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report it not assigned anymore by the current DDFIP" do
      let(:report) { create(:report, :accepted_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is now rejected by the current DDFIP" do
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
    before { sign_in_as(:organization_admin, organization: report.ddfip) }

    context "when report is assigned" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "undos report assignment" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("accepted")
          .and change(report, :assigned_at).to(nil)
          .and not_change(report, :office_id)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement n'est plus assigné.",
          delay:  3000
        )
      end
    end
  end
end
