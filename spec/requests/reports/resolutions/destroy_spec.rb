# frozen_string_literal: true

require "rails_helper"
require_relative "../shared_example_for_target_form_type"

RSpec.describe "Reports::ResolutionsController#destroy" do
  subject(:request) do
    delete "/signalements/resolve/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:report) { create(:report, :resolved_as_applicable) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP form admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    context "when report has been resolved by the current DDFIP" do
      let(:report) { create(:report, :resolved_as_applicable, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
    end

    context "when report it not resolved anymore by the current DDFIP" do
      let(:report) { create(:report, :assigned_to_office, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
      it_behaves_like "when current user administrates any other form_type" do
        it_behaves_like "it allows access to DDFIP user"
      end
    end

    context "when report has already been approved by the current DDFIP" do
      let(:report) { create(:report, :approved_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end

    context "when report has already been canceled by the current DDFIP" do
      let(:report) { create(:report, :canceled_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "when current user administrates the form_type" do
        it_behaves_like "it denies access to DDFIP user"
      end
    end
  end

  describe "responses" do
    before { sign_in_as(organization: report.ddfip) }

    context "when report is resolved" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "undoes report resolution" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("assigned")
          .and change(report, :resolved_at).to(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le statut du signalement a été réinitialisé.",
          delay:  3000
        )
      end
    end

    context "when report it not resolved anymore" do
      let(:report) { create(:report, :assigned_to_office) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }
    end
  end
end
