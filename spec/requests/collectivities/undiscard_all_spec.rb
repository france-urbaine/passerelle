# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#undiscard_all" do
  subject(:request) do
    patch "/collectivites/undiscard", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata.fetch(:params, { ids: collectivities.take(2).map(&:id) }) }

  let!(:collectivities) { create_list(:collectivity, 3, :discarded) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(-2) }

      it "undiscards the selected collectivities" do
        expect {
          request
          collectivities.each(&:reload)
        }.to change(collectivities[0], :discarded_at).to(nil)
          .and change(collectivities[1], :discarded_at).to(nil)
          .and maintain(collectivities[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des collectivités sélectionnées a été annulée.",
          delay: 3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(-3) }
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
