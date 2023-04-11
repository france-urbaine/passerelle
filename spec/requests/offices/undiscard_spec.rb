# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficesController#undiscard" do
  subject(:request) do
    patch "/guichets/#{office.id}/undiscard", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { |e| e.metadata[:params] }

  let!(:office) { create(:office, :discarded) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/guichets") }
    it { expect { request }.to change(Office.discarded, :count).by(-1) }

    it "undiscards the office" do
      expect {
        request
        office.reload
      }.to change(office, :discarded_at).to(nil)
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "cancel",
        title: "La suppression du guichet a été annulée.",
        delay: 3000
      )
    end

    context "when office is not discarded" do
      let(:office) { create(:office) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect { request and office.reload }.not_to change(office, :discarded_at).from(nil) }
    end

    context "when office is missing" do
      let(:office) { Office.new(id: Faker::Internet.uuid) }

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
    it { expect { request and office.reload }.not_to change(office, :discarded_at).from(be_present) }
  end
end
