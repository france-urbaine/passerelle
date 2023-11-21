# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OfficesController#undiscard_all" do
  subject(:request) do
    patch "/organisation/guichets/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)   { create(:ddfip) }
  let!(:offices) { create_list(:office, 3, :discarded, ddfip: ddfip) }
  let!(:ids)     { offices.map(&:id).take(2) }

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

    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.to change(Office.discarded, :count).by(-2) }

      it "undiscards the selected offices" do
        expect {
          request
          offices.each(&:reload)
        }.to change(offices[0], :discarded_at).to(nil)
          .and change(offices[1], :discarded_at).to(nil)
          .and not_change(offices[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "done",
          icon:   "arrow-path",
          header: "La suppression des guichets sélectionnés a été annulée.",
          delay:  3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.to change(Office.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.not_to change(Office.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Office.discarded, :count) }
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
