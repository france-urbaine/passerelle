# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DDFIPsController#destroy" do
  subject(:request) do
    delete "/ddfips/#{ddfip.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip) { create(:ddfip) }

  context "when requesting HTML" do
    context "when the DDFIP is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.to change(DDFIP.discarded, :count).by(1) }

      it "discards the ddfip" do
        expect {
          request
          ddfip.reload
        }.to change(ddfip, :discarded_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "La DDFIP a été supprimée.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:        10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/ddfips/#{ddfip.id}/undiscard",
          params: {}
        )
      end
    end

    context "when the DDFIP is already discarded" do
      before { ddfip.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DDFIP.discarded, :count).from(1) }
    end

    context "when DDFIP is missing" do
      before { ddfip.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
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

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(DDFIP.discarded, :count).from(0) }
  end
end
