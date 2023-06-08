# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#undiscard" do
  subject(:request) do
    patch "/collectivites/#{collectivity.id}/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:collectivity) { create(:collectivity, :discarded) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it allows access to super admin"

    context "when the collectivity is the organization of the current user" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when the collectivity is owned by the current user's publisher organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the collectivity is discarded" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(-1) }

      it "undiscards the collectivity" do
        expect { request and collectivity.reload }
          .to change(collectivity, :discarded_at).to(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression de la collectivité a été annulée.",
          delay: 3000
        )
      end
    end

    context "when the collectivity is not discarded" do
      before { collectivity.undiscard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :discarded_at).from(nil) }
    end

    context "when the collectivity is missing" do
      before { collectivity.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://www.example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://www.example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
