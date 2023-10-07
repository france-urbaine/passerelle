# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DDFIPsController#undiscard_all" do
  subject(:request) do
    patch "/admin/ddfips/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfips) do
    [
      create(:ddfip, :discarded),
      create(:ddfip, :discarded),
      create(:ddfip, :discarded),
      create(:ddfip)
    ]
  end

  let!(:ids) { ddfips.take(2).map(&:id) }

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

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect { request }.to change(DDFIP.discarded, :count).by(-2) }

      it "undiscards the selected ddfips" do
        expect {
          request
          ddfips.each(&:reload)
        }.to change(ddfips[0], :discarded_at).to(nil)
          .and change(ddfips[1], :discarded_at).to(nil)
          .and not_change(ddfips[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des DDFIPs sélectionnées a été annulée.",
          delay: 3000
        )
      end
    end

    context "with ids from already undiscarded DDFIPs" do
      let(:ids) { ddfips.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { ddfips.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(DDFIP.discarded, :count).by(-1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(DDFIP.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/ddfips") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(DDFIP.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://example.com/other/path") }
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
