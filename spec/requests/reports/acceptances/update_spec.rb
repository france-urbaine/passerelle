# frozen_string_literal: true

require "rails_helper"
require_relative "../shared_example_for_target_form_type"

RSpec.describe "Reports::AcceptancesController#update" do
  subject(:request) do
    patch "/signalements/accept/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report, :transmitted_to_ddfip) }

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
    it_behaves_like "it denies access to DDFIP form admin"

    context "when report has been transmitted to the current DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has not yet been transmitted to the current DDFIP" do
      let(:report) { create(:report, :ready, :made_for_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has been transmitted in sandbox to the current DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, :sandbox, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has already been accepted by the current DDFIP" do
      let(:report) { create(:report, :accepted_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has already been assigned by the current DDFIP" do
      let(:report) { create(:report, :assigned_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has already been rejected by the current DDFIP" do
      let(:report) { create(:report, :rejected_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: report.ddfip) }

    context "when report is waiting for acceptance" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "accepts the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("accepted")
          .and change(report, :accepted_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été accepté.",
          delay:  3000
        )
      end
    end

    context "when report is already accepted" do
      let(:report) { create(:report, :accepted_by_ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }
    end

    context "when report is already rejected" do
      let!(:report) { create(:report, :rejected_by_ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "accepts the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("accepted")
          .and change(report, :accepted_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été accepté.",
          delay:  3000
        )
      end
    end
  end
end
