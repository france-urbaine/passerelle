# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Collectivities::UsersController#destroy_all" do
  subject(:request) do
    delete "/admin/collectivites/#{collectivity.id}/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:collectivity) { create(:collectivity) }
  let!(:users) do
    [
      create(:user, organization: collectivity),
      create(:user, organization: collectivity),
      create(:user, organization: collectivity),
      create(:user),
      create(:user, :discarded, organization: collectivity)
    ]
  end

  let!(:ids) { users.take(2).map(&:id) }

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

    context "when the collectivity is the current organization" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when the collectivity is owned by the current organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect { request }.to change(User.discarded, :count).by(2) }

      it "discards the selected users" do
        expect {
          request
          users.each(&:reload)
        }.to change(users[0], :discarded_at).to(be_present)
          .and change(users[1], :discarded_at).to(be_present)
          .and not_change(users[2], :discarded_at).from(nil)
          .and not_change(users[3], :discarded_at).from(nil)
          .and not_change(users[4], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les utilisateurs sélectionnés ont été supprimés.",
          body:   "Toutes les données seront définitivement supprimées dans un délai de 1 jour.",
          delay:   10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/admin/collectivites/#{collectivity.id}/utilisateurs/undiscard",
          params: { ids: ids }
        )
      end
    end

    context "with ids from already discarded users" do
      let(:ids) { users.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with ids from users of any other organizations" do
      let(:ids) { users.slice(3, 1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(User.discarded, :count).by(3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "when the collectivity is discarded" do
      before { collectivity.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the collectivity is missing" do
      before { collectivity.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
    end
  end
end
