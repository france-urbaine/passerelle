# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OfficesController#destroy" do
  subject(:request) do
    delete "/organisation/guichets/#{office.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:office) { create(:office) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to publisher super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to DDFIP admin"

    context "when the office is owned by the current organization" do
      let(:office) { create(:office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP super admin"

      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: office.ddfip) }

    context "when the office is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.to change(Office.discarded, :count).by(1) }

      it "discards the office" do
        expect { request and office.reload }
          .to change(office, :discarded_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Le guichet a été supprimé.",
          body:   "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:   10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/organisation/guichets/#{office.id}/undiscard",
          params: {}
        )
      end
    end

    context "when the office is already discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Office.discarded, :count).from(1) }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
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
