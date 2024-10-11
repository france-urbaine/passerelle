# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::ResolutionsController#update" do
  subject(:request) do
    patch "/signalements/resolve/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { state: state, report: attributes }) }

  let!(:report) { create(:report, :assigned_to_office, competence:) }

  let(:state)      { "applicable" }
  let(:attributes) { { reponse: "Lorem lipsum", resolution_motif: "maj_local" } }
  let(:competence) { "evaluation_local_habitation" }

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

    context "when report has been assigned by the current DDFIP" do
      let(:report) { create(:report, :assigned_to_office, ddfip: current_user.organization, competence:) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has not yet been assigned by the current DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been resolved by the current DDFIP" do
      let(:report) { create(:report, :resolved_as_applicable, ddfip: current_user.organization, competence:) }

      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report has already been approved by the current DDFIP" do
      let(:report) { create(:report, :approved_by_ddfip, ddfip: current_user.organization, competence:) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has already been canceled by the current DDFIP" do
      let(:report) { create(:report, :canceled_by_ddfip, ddfip: current_user.organization, competence:) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(organization: report.ddfip) }

    context "when assigned report is going to be resolved as applicable" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "resolves the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("applicable")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolved_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le statut du signalement a mis à jour.",
          delay:  3000
        )
      end
    end

    context "when assigned report is going to be resolved as inapplicable" do
      let(:state) { "inapplicable" }
      let(:attributes) { { reponse: "Lorem lipsum", resolution_motif: "absence_incoherence" } }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "resolves the report" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("inapplicable")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolution_motif).to("absence_incoherence")
          .and change(report, :resolved_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le statut du signalement a mis à jour.",
          delay:  3000
        )
      end
    end

    context "when inapplicable report is going to be resolved as applicable" do
      let!(:report) { create(:report, :resolved_as_inapplicable, competence:) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "updates report resolution" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("applicable")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolved_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le statut du signalement a mis à jour.",
          delay:  3000
        )
      end
    end

    context "when applicable report is going to be resolved as inapplicable" do
      let(:state)      { "inapplicable" }
      let(:attributes) { { reponse: "Lorem lipsum", resolution_motif: "absence_incoherence" } }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "updates report resolution" do
        expect {
          request
          report.reload
        }
          .to  change(report, :updated_at)
          .and change(report, :state).to("inapplicable")
          .and change(report, :resolution_motif).to("absence_incoherence")
          .and change(report, :reponse).to("Lorem lipsum")
          .and change(report, :resolved_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le statut du signalement a mis à jour.",
          delay:  3000
        )
      end
    end
  end
end
