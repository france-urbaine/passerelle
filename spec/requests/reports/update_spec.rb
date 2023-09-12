# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#update" do
  subject(:request) do
    patch "/signalements/#{report.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { form: form_template, report: attributes }) }

  let!(:report) { create(:report) }

  let(:form_template) { "situation_majic" }
  let(:attributes) do
    { situation_annee_majic: 2022 }
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

    context "when report has been reported by current user collectivity" do
      let(:report) { create(:report, :reported_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when report has been transmitted by current user collectivity" do
      let(:report) { create(:report, :transmitted_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been reported through API for current user collectivity" do
      let(:report) { create(:report, :reported_through_api, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been transmitted through API for current user collectivity" do
      let(:report) { create(:report, :transmitted_through_api, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when report has been reported by current user publisher" do
      let(:report) { create(:report, :reported_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when report has been transmitted by current user publisher" do
      let(:report) { create(:report, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when report has been transmitted to current user DDFIP" do
      let(:report) { create(:report, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user" do
        context "when current user is member of targeted office" do
          before { create(:office, competences: [report.form_type], users: [current_user], communes: [report.commune]) }

          it { expect(response).to have_http_status(:forbidden) }
        end
      end
    end

    context "when report package has been assigned by the current DDFIP" do
      let(:report) { create(:report, :package_assigned_by_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user" do
        context "when current user is member of targeted office" do
          before { create(:office, competences: [report.form_type], users: [current_user], communes: [report.commune]) }

          include_examples "it allows access"
        end
      end
    end
  end

  describe "responses" do
    let(:report) { create(:report, :reported_through_web_ui) }

    before { sign_in_as(organization: report.collectivity) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "updates the report" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :situation_annee_majic).to(2022)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid date" do
      let!(:report) { create(:report, form_type: "evaluation_local_habitation", anomalies: %w[consistance]) }

      let(:form_template) { "situation_evaluation" }
      let(:attributes) do
        { situation_date_mutation: "0003-07-27" }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and report.reload }.not_to change(report, :updated_at) }
    end

    context "when the report is discarded" do
      before { report.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the package is discarded" do
      before { report.package.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the report is missing" do
      before { report.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
