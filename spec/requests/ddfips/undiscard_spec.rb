# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DDFIPsController#undiscard" do
  subject(:request) do
    patch "/ddfips/#{ddfip.id}/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip) { create(:ddfip, :discarded) }

  context "when requesting HTML" do
    context "when the DDFIP is discarded" do
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
    end

    context "when the DDFIP is not discarded" do
      before { ddfip.undiscard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :discarded_at).from(nil) }
    end

    context "when the DDFIP is missing" do
      before { ddfip.destroy }

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

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and ddfip.reload }.not_to change(ddfip, :discarded_at).from(be_present) }
  end
end
