# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#update" do
  subject(:request) do
    delete "/paquets/#{package.id}", as:, headers:, params:
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

      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when package has been transmitted by current user collectivity" do
      let(:package) { create(:package, :transmitted_through_web_ui, collectivity: current_user.organization) }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when package has been packed by current user publisher" do
      let(:package) { create(:package, :packed_through_api, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end

    context "when package has been transmitted by current user publisher" do
      let(:package) { create(:package, :transmitted_through_api, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end

    context "when package has been transmitted to current user DDFIP" do
      let(:package) { create(:package, :transmitted_to_ddfip, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP user"
    end
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: package.collectivity) }

      context "when the package is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets") }
        it { expect { request }.to change(Package.discarded, :count).by(1) }

        it "discards the package" do
          expect { request and package.reload }
            .to change(package, :discarded_at).to(be_present)
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            type:        "success",
            title:       "Le paquet a été supprimé.",
            description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
            delay:        10_000
          )
        end

        it "sets a flash action to cancel" do
          expect(flash).to have_flash_actions.to include(
            label:  "Annuler",
            method: "patch",
            url:    "/paquets/#{package.id}/undiscard",
            params: {}
          )
        end
      end

      context "when the package is discarded" do
        before { package.discard }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
        it { expect { request }.not_to change(Package.discarded, :count).from(1) }
      end

      context "when the package is missing" do
        before { package.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/paquets") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
      end

      context "with redirect parameter", params: { redirect: "/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
        it { expect(flash).to have_flash_actions }
      end
    end
  end
end
