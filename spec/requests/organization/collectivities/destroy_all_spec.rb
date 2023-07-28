# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::CollectivitiesController#destroy_all" do
  subject(:request) do
    delete "/organisation/collectivites", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher) { create(:publisher) }
  let!(:collectivities) do
    [
      create(:collectivity, publisher: publisher, allow_publisher_management: true),
      create(:collectivity, publisher: publisher, allow_publisher_management: true),
      create(:collectivity, publisher: publisher),
      create(:collectivity, allow_publisher_management: true),
      create(:collectivity, :discarded, publisher: publisher, allow_publisher_management: true)
    ]
  end

  let(:ids) { collectivities.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to publisher super admin"
  end

  describe "responses" do
    before { sign_in_as(:publisher, organization: publisher) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(2) }

      it "discards the selected collectivities" do
        expect {
          request
          collectivities.each(&:reload)
        }.to   change(collectivities[0], :discarded_at).to(be_present)
          .and change(collectivities[1], :discarded_at).to(be_present)
          .and not_change(collectivities[2], :discarded_at).from(nil)
          .and not_change(collectivities[3], :discarded_at).from(nil)
          .and not_change(collectivities[4], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Les collectivités sélectionnées ont été supprimées.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 30 jours.",
          delay:        10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/organisation/collectivites/undiscard",
          params: { ids: ids }
        )
      end
    end

    context "with ids from already discarded collectivities" do
      let(:ids) { collectivities.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to not_change(Collectivity.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { collectivities.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(Collectivity.discarded, :count).by(1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(Collectivity.discarded, :count).by(2) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites") }
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
