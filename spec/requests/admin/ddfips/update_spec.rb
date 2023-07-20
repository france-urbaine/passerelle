# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DDFIPsController#update" do
  subject(:request) do
    patch "/admin/ddfips/#{ddfip.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ddfip: updated_attributes }) }

  let!(:ddfip) { create(:ddfip, name: "Ddfip de Pyrénée-Atlantique") }

  let(:updated_attributes) do
    { name: "DDFIP des Pyrénées-Atlantiques" }
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

    context "when the DDFIP is the current organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }

      it "updates the ddfip" do
        expect { request and ddfip.reload }
          .to  change(ddfip, :updated_at)
          .and change(ddfip, :name).to("DDFIP des Pyrénées-Atlantiques")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid attributes" do
      let(:updated_attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :updated_at) }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :name) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :updated_at) }
    end

    context "when the DDFIP is discarded" do
      before { ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is missing" do
      before { ddfip.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
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
