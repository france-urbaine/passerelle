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
  let!(:report) { create(:report, :transmitted_to_ddfip, ddfip:) }

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

    context "when report has not yet been transmitted to the current DDFIP" do
      let(:report) { create(:report, :ready, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report has been transmitted to the current DDFIP" do
      let(:report) { create(:report, :transmitted, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is transmitted in sandbox" do
      let(:report) { create(:report, :transmitted, :sandbox, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is already assigned" do
      let(:report) { create(:report, :assigned, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is already denied" do
      let(:report) { create(:report, :denied, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when report is already approved" do
      let(:report) { create(:report, :approved, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end

    context "when report is already rejected" do
      let(:report) { create(:report, :rejected, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "with valid office" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "assigns the report" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :state).to("processing")
          .and change(report, :assigned_at).to(be_present)
          .and change(report, :office_id).to(office.id)
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
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and report.reload }.not_to change(report, :updated_at) }
    end

    context "when report is already assigned" do
      let!(:another_office) { create(:office, ddfip:) }
      let!(:report)         { create(:report, :assigned_by_ddfip, ddfip:, office: another_office) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "updates the office" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :office_id).to(office.id)
          .and not_change(report, :state).from("processing")
          .and not_change(report, :assigned_at)
      end
    end
  end
end
