# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#undiscard_all" do
  subject(:request) do
    patch "/ddfips/undiscard", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata.fetch(:params, { ids: ddfips.take(2).map(&:id) }) }

  let!(:ddfips) { create_list(:ddfip, 3, :discarded) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.to change(DDFIP.discarded, :count).by(-2) }

      it "undiscards the selected ddfips" do
        expect {
          request
          ddfips.each(&:reload)
        }.to change(ddfips[0], :discarded_at).to(nil)
          .and change(ddfips[1], :discarded_at).to(nil)
          .and not_change(ddfips[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des DDFIPs sélectionnées a été annulée.",
          delay: 3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.to change(DDFIP.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with missing ids parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
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
    it { expect { request }.not_to change(DDFIP.discarded, :count) }
  end
end
