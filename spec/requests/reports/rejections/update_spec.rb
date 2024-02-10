# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::RejectionsController#update" do
  subject(:request) do
    patch "/signalements/reject/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }

  let!(:report) { create(:report, :transmitted_to_ddfip) }

  let(:attributes) do
    { reponse: "Lorem lipsum" }
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

    context "when report has been transmitted to the current DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has not yet been transmitted to the current DDFIP" do
      let(:report) { create(:report, :ready, :made_for_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has been transmitted in sandbox to the current DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, :sandbox, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been rejected by the current DDFIP" do
      let(:report) { create(:report, :rejected_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has already been accepted by the current DDFIP" do
      let(:report) { create(:report, :accepted_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has already been assigned by the current DDFIP" do
      let(:report) { create(:report, :assigned_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: report.ddfip) }

    context "when report is waiting for acceptance" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "rejects the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("rejected")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :returned_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été rejeté.",
          delay:  3000
        )
      end
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected_by_ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }
    end

    context "when report is already accepted" do
      let!(:report) { create(:report, :accepted_by_ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "rejects the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("rejected")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :returned_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été rejeté.",
          delay:  3000
        )
      end
    end
  end
end
