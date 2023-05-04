# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#destroy_all" do
  subject(:request) do
    delete "/collectivites", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata.fetch(:params, { ids: collectivities.take(2).map(&:id) }) }

  let!(:collectivities) { create_list(:collectivity, 3) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(2) }

      it "discards the selected collectivities" do
        expect {
          request
          collectivities.each(&:reload)
        }.to change(collectivities[0], :discarded_at).to(be_present)
          .and change(collectivities[1], :discarded_at).to(be_present)
          .and not_change(collectivities[2], :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Les collectivités sélectionnées ont été supprimées.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:        10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/collectivites/undiscard",
          params: {
            redirect: "/collectivites",
            ids:      collectivities.take(2).map(&:id)
          }
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with missing ids parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/editeur/12345")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeur/12345") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Collectivity.discarded, :count) }
  end
end
