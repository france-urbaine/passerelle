# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#destroy" do
  subject(:request) do
    delete "/editeurs/#{publisher.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:publisher) { create(:publisher) }

  context "when requesting HTML" do
    context "when the publisher is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.to change(Publisher.discarded, :count).by(1) }

      it "discards the publisher" do
        expect {
          request
          publisher.reload
        }.to change(publisher, :discarded_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "L'éditeur a été supprimé.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:       10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/editeurs/#{publisher.id}/undiscard",
          params: {}
        )
      end
    end

    context "when the publisher is already discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request }.not_to change(Publisher.discarded, :count).from(1) }
    end

    context "when the publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
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
    it { expect { request }.not_to change(Publisher.discarded, :count).from(0) }
  end
end
