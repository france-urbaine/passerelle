# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#destroy" do
  subject(:request) do
    delete "/collectivites/#{collectivity.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata[:params] }

  let!(:collectivity) { create(:collectivity) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/collectivites") }
    it { expect { request }.to change(Collectivity.discarded, :count).by(1) }

    it "discards the collectivity" do
      expect {
        request
        collectivity.reload
      }.to change(collectivity, :discarded_at).to(be_present)
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:        "success",
        title:       "La collectivité a été supprimée.",
        description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
        delay:        10_000
      )
    end

    it "sets a flash action to cancel" do
      expect(flash).to have_flash_actions.to include(
        label:  "Annuler",
        method: "patch",
        url:    "/collectivites/#{collectivity.id}/undiscard",
        params: {}
      )
    end

    context "when the collectivity is already discarded" do
      let(:collectivity) { create(:collectivity, :discarded) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request }.not_to change(Collectivity.discarded, :count).from(1) }
    end

    context "when the collectivity is missing" do
      let(:collectivity) { Collectivity.new(id: Faker::Internet.uuid) }

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
    it { expect { request }.not_to change(Collectivity.discarded, :count).from(0) }
  end
end
