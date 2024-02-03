# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::DenialsController#update" do
  subject(:request) do
    patch "/signalements/deny/#{report.id}", as:, headers:, params:
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
    before { sign_in_as(:organization_admin, organization: report.ddfip) }

    context "when report is unassigned" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "denies the report" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and change(report, :reponse).to("Lorem lipsum")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été retourné à la collectivité.",
          delay:  3000
        )
      end
    end

    context "when report is already denied" do
      let(:report) { create(:report, :transmitted_to_ddfip, :denied) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "updates the denial response" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and not_change(report, :state)
          .and not_change(report, :denied_at)
          .and change(report, :reponse).to("Lorem lipsum")
      end
    end

    context "when report is already assigned" do
      let!(:report) { create(:report, :assigned_by_ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements/#{report.id}") }

      it "approves the report" do
        expect { request and report.reload }
          .to  change(report, :updated_at)
          .and change(report, :state).to("denied")
          .and change(report, :denied_at).to(be_present)
          .and change(report, :assigned_at).to(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le signalement a été retourné à la collectivité.",
          delay:  3000
        )
      end
    end
  end
end
