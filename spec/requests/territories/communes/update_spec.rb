# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Territories::CommunesController#update" do
  subject(:request) do
    patch "/territoires/communes/#{commune.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { commune: updated_attributes }) }

  let!(:commune) { create(:commune, name: "L'AEbergement-ClÉmenciat") }

  let(:updated_attributes) do
    { name: "L'Abergement-Clémenciat" }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/territoires/communes") }

      it "updates the commune" do
        expect { request and commune.reload }
          .to  change(commune, :updated_at)
          .and change(commune, :name).to("L'Abergement-Clémenciat")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end
    end

    context "with invalid attributes" do
      let(:updated_attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and commune.reload }.not_to change(commune, :updated_at) }
      it { expect { request and commune.reload }.not_to change(commune, :name) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/territoires/communes") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and commune.reload }.not_to change(commune, :updated_at) }
    end

    context "when the commune is missing" do
      before { commune.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/territoires/communes") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
