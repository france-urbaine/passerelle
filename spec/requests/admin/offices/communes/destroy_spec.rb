# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Offices::CommunesController#destroy" do
  subject(:request) do
    delete "/admin/guichets/#{office.id}/communes/#{commune.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip)   { create(:ddfip) }
  let!(:office)  { create(:office, ddfip: ddfip, communes: [commune]) }
  let!(:commune) { create(:commune, departement: ddfip.departement) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the office is owned by the current organization" do
      let(:office) { create(:office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the commune is accessible" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/guichets/#{office.id}") }

      it "removes the communes from the office" do
        expect { request and office.communes.reload }
          .to change { office.communes.ids }.from([commune.id]).to([])
      end

      it "doesn't destroy the commune" do
        expect { request and commune.reload }
          .not_to change(commune, :persisted?)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "La commune a été exclue du guichet.",
          delay:   10_000
        )
      end

      it "doens't set a flash action to cancel" do
        expect(flash).not_to have_flash_actions
      end
    end

    context "when the commune doesn't belong to office" do
      before { office.communes = [] }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/guichets/#{office.id}") }
      it { expect { request and office.communes.reload }.not_to change { office.communes.ids } }
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
  end
end
