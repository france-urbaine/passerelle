# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#destroy" do
  subject(:request) do
    delete "/ddfips/#{ddfip.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata[:params] }

  let!(:ddfip) { create(:ddfip) }

  context "when requesting HTML" do
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

    context "when ddfip is already discarded" do
      let(:ddfip) { create(:ddfip, :discarded) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request }.not_to change(DDFIP.discarded, :count).from(1) }
    end

    context "when ddfip is missing" do
      let(:ddfip) { DDFIP.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with redirect parameter", params: { redirect: "/editeur/12345" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeur/12345") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(DDFIP.discarded, :count).from(0) }
  end
end
