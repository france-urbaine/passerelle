# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::UsersController#destroy_all" do
  subject(:request) do
    delete "/organisation/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:organization) { create(%i[publisher ddfip collectivity].sample) }
  let!(:users) do
    [
      create(:user, organization: organization),
      create(:user, organization: organization),
      create(:user, :discarded, organization: organization),
      create(:user),
      create(:user),
      create(:user, organization: organization)
    ]
  end

  let!(:ids) { users.map(&:id).take(4) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP supervisor"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: organization) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect { request }.to change(User.discarded, :count).by(2) }

      it "discards the selected users" do
        expect {
          request
          users.each(&:reload)
        }.to   change(users[0], :discarded_at).to(be_present)
          .and change(users[1], :discarded_at).to(be_present)
          .and not_change(users[2], :discarded_at).from(be_present)
          .and not_change(users[3], :discarded_at).from(nil)
          .and not_change(users[4], :discarded_at).from(nil)
          .and not_change(users[5], :discarded_at).from(nil)
          .and not_change(current_user, :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les utilisateurs sélectionnés ont été supprimés.",
          body:   "Toutes les données seront définitivement supprimées dans un délai de 1 jour.",
          delay:    10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/organisation/utilisateurs/undiscard",
          params: { ids: ids }
        )
      end
    end

    context "with ids from already discarded users" do
      let(:ids) { users[2, 1].map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { users.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.to change(User.discarded, :count).by(1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }

      it "all users expect the one signed in" do
        expect {
          request
          users.each(&:reload)
        } .to change(User.discarded, :count).by(3)
          .and change(users[0], :discarded_at).to(be_present)
          .and change(users[1], :discarded_at).to(be_present)
          .and not_change(users[2], :discarded_at).from(be_present)
          .and not_change(users[3], :discarded_at).from(nil)
          .and not_change(users[4], :discarded_at).from(nil)
          .and change(users[5], :discarded_at).to(be_present)
          .and not_change(current_user, :discarded_at).from(nil)
      end
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
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
