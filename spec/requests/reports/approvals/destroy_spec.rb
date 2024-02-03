# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::ApprovalsController#destroy" do
  subject(:request) do
    delete "/signalements/approve/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report, :approved_by_ddfip) }

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

    context "when report has not yet been assigned by the current DDFIP" do
      let(:report) { create(:report, :transmitted, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has been approved by the current DDFIP" do
      let(:report) { create(:report, :approved, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has been rejected by the current DDFIP" do
      let(:report) { create(:report, :denied, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been unapproved by the current DDFIP" do
      let(:report) { create(:report, :assigned, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(organization: report.ddfip) }

    context "with report is approved" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "unapproves the report" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :state).to("processing")
          .and change(report, :approved_at).to(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement n'est plus approuvé.",
          delay:  3000
        )
      end
    end
  end
end
