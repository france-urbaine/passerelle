# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::CommunesController#destroy_all" do
  subject(:request) do
    delete "/guichets/#{office.id}/communes", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)    { create(:ddfip) }
  let!(:office)   { create(:office, ddfip: ddfip, communes: communes) }
  let!(:communes) { create_list(:commune, 3, departement: ddfip.departement) }
  let!(:ids)      { communes.take(2).map(&:id) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "removes the selected communes from the office" do
        expect {
          request
          office.communes.reload
        }.to change { office.communes.count }.from(3).to(1)
      end

      it "doesn't destroy the selected communes" do
        expect {
          request
          communes.each(&:reload)
        }.to not_change(communes[0], :persisted?)
          .and not_change(communes[1], :persisted?)
          .and not_change(communes[2], :persisted?)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les communes sélectionnées ont été exclues du guichet.",
          delay: 10_000
        )
      end

      it "doens't set a flash action to cancel" do
        expect(flash).not_to have_flash_actions
      end
    end

    context "with ids from communes which are not linked to the office" do
      before { office.communes = [] }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.to change { office.communes.count }.by(-3) }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "when the office is discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { office.ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Commune, :count) }
  end
end