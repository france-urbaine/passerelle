# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPsController#destroy" do
  subject(:request) do
    delete "/admin/dgfips/#{dgfip.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:dgfip) { create(:dgfip) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the DGFIP is the current organization" do
      let(:dgfip) { current_user.organization }

      it_behaves_like "it denies access to DGFIP user"
      it_behaves_like "it denies access to DGFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the DGFIP is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect { request }.to change(DGFIP.discarded, :count).by(1) }

      it "discards the dgfip" do
        expect { request and dgfip.reload }
          .to change(dgfip, :discarded_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "La DGFIP a été supprimée.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:        10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/admin/dgfips/#{dgfip.id}/undiscard",
          params: {}
        )
      end
    end

    context "when the DGFIP is already discarded" do
      before { dgfip.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DGFIP.discarded, :count).from(1) }
    end

    context "when the DGFIP is missing" do
      before { dgfip.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
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
