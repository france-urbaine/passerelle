# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#undiscard" do
  subject(:request) do
    patch "/ddfips/#{ddfip.id}/undiscard", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata[:params] }

  let!(:ddfip) { create(:ddfip, :discarded) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/ddfips") }
    it { expect { request }.to change(DDFIP.discarded, :count).by(-1) }

    it "undiscards the ddfip" do
      expect {
        request
        ddfip.reload
      }.to change(ddfip, :discarded_at).to(nil)
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "cancel",
        title: "La suppression de la DDFIP a été annulée.",
        delay: 3000
      )
    end

    context "when ddfip is not discarded" do
      let(:ddfip) { create(:ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :discarded_at).from(nil) }
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
    it { expect { request and ddfip.reload }.not_to change(ddfip, :discarded_at).from(be_present) }
  end
end
