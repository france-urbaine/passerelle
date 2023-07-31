# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::UsersController#destroy" do
  subject(:request) do
    delete "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let(:publisher)     { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher, allow_publisher_management: true) }
  let!(:user)         { create(:user, organization: collectivity) }

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

    it_behaves_like "it responds with not found to publisher user"
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to publisher super admin"

    context "when the collectivity is the current organization" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
      it_behaves_like "it denies access to collectivity super admin"
    end

    context "when the collectivity is owned by but didn't allow to be managed by the current publisher" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization, allow_publisher_management: false) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
      it_behaves_like "it denies access to publisher super admin"
    end

    context "when the collectivity is owned by and allowed to be managed by the current publisher" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization, allow_publisher_management: true) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher super admin"
    end

    context "when the collectivity is likely to send reports to current DDFIP" do
      let(:commune)      { create(:commune, departement: current_user.organization.departement) }
      let(:collectivity) { create(:collectivity, territory: commune) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to DDFIP super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "when the user is active" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
      it { expect { request }.to change(User.discarded, :count).by(1) }

      it "discards the user" do
        expect { request and user.reload }
          .to change(user, :discarded_at).to(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "L'utilisateur a été supprimé.",
          description: "Toutes les données seront définitivement supprimées dans un délai de 1 jour.",
          delay:       10_000
        )
      end

      it "sets a flash action to cancel" do
        expect(flash).to have_flash_actions.to include(
          label:  "Annuler",
          method: "patch",
          url:    "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}/undiscard",
          params: {}
        )
      end
    end

    context "when the user is already discarded" do
      before { user.discard }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).to have_flash_actions }
      it { expect { request }.not_to change(User.discarded, :count).from(1) }
    end

    context "when the collectivity is discarded" do
      before { user.organization.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is missing" do
      before { user.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
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
