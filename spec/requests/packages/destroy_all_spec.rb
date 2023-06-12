# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#destroy_all" do
  subject(:request) do
    delete "/paquets", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher)      { create(:publisher) }
  let!(:collectivities) { create_list(:collectivity, 2, publisher: publisher) }
  let!(:packages) do
    [
      create(:package, collectivity: collectivities[0]),
      create(:package, collectivity: collectivities[0]),
      create(:package, collectivity: collectivities[0], publisher: publisher),
      create(:package, :transmitted, :with_reports, collectivity: collectivities[1]),
      create(:package, :transmitted, :with_reports, collectivity: collectivities[0], publisher: publisher),
      create(:package, :discarded, collectivity: collectivities[0])
    ]
  end

  let!(:ids) { packages.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP user"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(organization: collectivities[0]) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect { request }.to change(Package.discarded, :count).by(2) }

      it "discards the selected packages" do
        expect {
          request
          packages.each(&:reload)
        }
          .to  change(packages[0], :discarded_at).to(be_present)
          .and change(packages[1], :discarded_at).to(be_present)
          .and not_change(packages[2], :discarded_at).from(nil)
          .and not_change(packages[5], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Les paquets sélectionnés ont été supprimés.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:       10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/paquets/undiscard",
          params: { ids: ids }
        )
      end
    end

    context "with only ids of already discarded packages" do
      let(:ids) { packages.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to not_change(Package.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { packages.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(Package.discarded, :count).by(1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(Package.discarded, :count).by(2) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Package.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Package.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Package.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/paquets") }
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
