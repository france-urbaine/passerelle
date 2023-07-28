# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Packages::ApprovalsController#destroy" do
  subject(:request) do
    delete "/paquets/#{package.id}/approval", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:package) { create(:package) }

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

    context "when package has been packed by current user collectivity" do
      let(:package) { create(:package, :packed_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when package has been transmitted by current user collectivity" do
      let(:package) { create(:package, :transmitted_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when package has been packed by current user publisher" do
      let(:package) { create(:package, :packed_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when package has been transmitted by current user publisher" do
      let(:package) { create(:package, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when package has been transmitted to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when package has been approved to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, :approved, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end

    context "when package has been rejected to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, :rejected, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    let(:package) { create(:package, :transmitted_to_ddfip, ddfip: ddfip) }
    let(:ddfip)   { create(:ddfip) }

    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "when the package is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets/#{package.id}") }

      it "approves the package" do
        expect { request and package.reload }
          .to change(package, :rejected_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Le paquet a été rejeté.",
          delay: 3000
        )
      end
    end

    context "when the package is discarded" do
      before { package.discard }

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the package is missing" do
      before { package.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
