# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#undiscard" do
  subject(:request) do
    patch "/editeurs/#{publisher.id}/undiscard", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata[:params] }

  let!(:publisher) { create(:publisher, :discarded) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/editeurs") }
    it { expect { request }.to change(Publisher.discarded, :count).by(-1) }

    it "undiscards the publisher" do
      expect {
        request
        publisher.reload
      }.to change(publisher, :discarded_at).to(nil)
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "cancel",
        title: "La suppression de l'éditeur a été annulée.",
        delay: 3000
      )
    end

    context "when publisher is not discarded" do
      let(:publisher) { create(:publisher) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request and publisher.reload }.not_to change(publisher, :discarded_at).from(nil) }
    end

    context "when publisher is missing" do
      let(:publisher) { Publisher.new(id: Faker::Internet.uuid) }

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
    it { expect { request and publisher.reload }.not_to change(publisher, :discarded_at).from(be_present) }
  end
end
