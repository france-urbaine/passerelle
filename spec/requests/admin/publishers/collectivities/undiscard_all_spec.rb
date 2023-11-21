# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Publishers::CollectivitiesController#undiscard_all" do
  subject(:request) do
    patch "/admin/editeurs/#{publisher.id}/collectivites/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher) { create(:publisher) }
  let!(:collectivities) do
    [
      create(:collectivity, :discarded, publisher: publisher),
      create(:collectivity, :discarded, publisher: publisher),
      create(:collectivity, :discarded, publisher: publisher),
      create(:collectivity, :discarded),
      create(:collectivity, publisher: publisher)
    ]
  end

  let(:ids) { collectivities.take(2).map(&:id) }

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

    context "when the publisher is the current organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect { request }.to change(Collectivity.discarded, :count).by(-2) }

      it "undiscards the selected collectivities" do
        expect {
          request
          collectivities.each(&:reload)
        }.to change(collectivities[0], :discarded_at).to(nil)
          .and change(collectivities[1], :discarded_at).to(nil)
          .and not_change(collectivities[2], :discarded_at).from(be_present)
          .and not_change(collectivities[3], :discarded_at).from(be_present)
          .and not_change(collectivities[4], :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "done",
          icon:   "arrow-path",
          header: "La suppression des collectivités sélectionnées a été annulée.",
          delay:  3000
        )
      end
    end

    context "with ids from already undiscarded collectivities" do
      let(:ids) { collectivities.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with ids from collectivities of any other publishers" do
      let(:ids) { collectivities[3, 1].map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(Collectivity.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Collectivity.discarded, :count) }
    end

    context "when the publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
