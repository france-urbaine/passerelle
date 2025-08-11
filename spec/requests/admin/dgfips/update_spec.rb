# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPsController#update" do
  subject(:request) do
    patch "/admin/dgfip", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { dgfip: updated_attributes }) }

  let!(:dgfip) { DGFIP.find_or_create_singleton_record }

  let(:updated_attributes) do
    { name: "Ministère de l'Économie et des Finances" }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the DGFIP is the current organization" do
      let(:dgfip) { current_user.organization }

      it_behaves_like "it denies access to DGFIP user"
      it_behaves_like "it denies access to DGFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }

      it "updates the dgfip" do
        expect { request and dgfip.reload }
          .to  change(dgfip, :updated_at)
          .and change(dgfip, :name).to("Ministère de l'Économie et des Finances")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:   3000
        )
      end
    end

    context "with invalid attributes" do
      let(:updated_attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and dgfip.reload }.not_to change(dgfip, :updated_at) }
      it { expect { request and dgfip.reload }.not_to change(dgfip, :name) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and dgfip.reload }.not_to change(dgfip, :updated_at) }
    end

    context "when the DGFIP is discarded" do
      before { dgfip.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
      it { expect(flash).to have_flash_notice }
    end

    context "when the DGFIP is missing" do
      before { dgfip.destroy }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
      it { expect(flash).to have_flash_notice }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
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
