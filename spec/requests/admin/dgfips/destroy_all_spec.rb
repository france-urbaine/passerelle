# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPsController#destroy_all" do
  subject(:request) do
    delete "/admin/dgfips", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:dgfips) do
    [
      create(:dgfip),
      create(:dgfip),
      create(:dgfip),
      create(:dgfip, :discarded)
    ]
  end

  let!(:ids) { dgfips.take(2).map(&:id) }

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
  end

  describe "responses" do
    # Log in as a Publisher to avoid creating another DGFIP
    # which would produce flaky tests.
    #
    before { sign_in_as(:publisher, :super_admin) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect { request }.to change(DGFIP.discarded, :count).by(2) }

      it "discards the selected dgfips" do
        expect {
          request
          dgfips.each(&:reload)
        }.to change(dgfips[0], :discarded_at).to(be_present)
          .and change(dgfips[1], :discarded_at).to(be_present)
          .and not_change(dgfips[2], :discarded_at).from(nil)
          .and not_change(dgfips[3], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Les DGFIPs sélectionnées ont été supprimées.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:        10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/admin/dgfips/undiscard",
          params: { ids: ids }
        )
      end
    end

    context "with ids from already discarded DGFIPs" do
      let(:ids) { dgfips.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DGFIP.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { dgfips.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(DGFIP.discarded, :count).by(1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(DGFIP.discarded, :count).by(3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DGFIP.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DGFIP.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(DGFIP.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfips") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
    end
  end
end
