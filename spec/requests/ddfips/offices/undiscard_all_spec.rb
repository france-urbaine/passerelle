# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ddfips::OfficesController#undiscard_all" do
  subject(:request) do
    patch "/ddfips/#{ddfip.id}/guichets/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)   { create(:ddfip) }
  let!(:offices) { create_list(:office, 3, :discarded, ddfip: ddfip) }
  let!(:ids)     { offices.take(2).map(&:id) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect { request }.to change(Office.discarded, :count).by(-2) }

      it "undiscards the selected offices" do
        expect {
          request
          offices.each(&:reload)
        }.to change(offices[0], :discarded_at).to(nil)
          .and change(offices[1], :discarded_at).to(nil)
          .and not_change(offices[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des guichets sélectionnés a été annulée.",
          delay: 3000
        )
      end
    end

    context "with ids from offices of any other DDFIP" do
      let(:offices) { create_list(:user, 3, :discarded) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(Office.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "when DDFIP is discarded" do
      before { ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when DDFIP is missing" do
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
    it { expect { request }.not_to change(Office.discarded, :count) }
  end
end
