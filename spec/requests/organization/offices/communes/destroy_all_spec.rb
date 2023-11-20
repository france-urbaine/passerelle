# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Offices::CommunesController#destroy_all" do
  subject(:request) do
    delete "/organisation/guichets/#{office.id}/communes", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)    { create(:ddfip) }
  let!(:office)   { create(:office, ddfip: ddfip, communes: communes) }
  let!(:communes) { create_list(:commune, 3, departement: ddfip.departement) }
  let!(:ids)      { communes.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to publisher super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to DDFIP admin"

    context "when the office is owned by the current organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP super admin"

      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }

      it "removes the selected communes from the office" do
        expect { request and office.communes.reload }
          .to change(office.communes, :count).from(3).to(1)
      end

      it "doesn't destroy the selected communes" do
        expect { request and communes.each(&:reload) }
          .to  not_change(communes[0], :persisted?)
          .and not_change(communes[1], :persisted?)
          .and not_change(communes[2], :persisted?)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les communes sélectionnées ont été exclues du guichet.",
          delay:  10_000
        )
      end

      it "doens't set a flash action to cancel" do
        expect(flash).not_to have_flash_actions
      end
    end

    context "with ids from communes which are not linked to the office" do
      before { office.communes = [] }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.to change { office.communes.count }.by(-3) }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.communes.count } }
      it { expect { request }.not_to change(Commune, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
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

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
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
end
