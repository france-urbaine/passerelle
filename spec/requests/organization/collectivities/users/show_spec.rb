# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::UsersController#show" do
  subject(:request) do
    get "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let(:publisher)     { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher) }
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

    context "when the collectivity is the organization of the current user" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
      it_behaves_like "it denies access to collectivity super admin"
    end

    context "when the collectivity is owned by the current user's publisher organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "when the user is active" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is discarded" do
      before { user.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.to include("Cet utilisateur est en cours de suppression.") }
    end

    context "when the collectivity is discarded" do
      before { user.organization.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.to include("Cette collectivité est en cours de suppression.") }
    end

    context "when the user is missing" do
      before { user.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.to include("Cet utilisateur n'a pas été trouvé ou n'existe plus.") }
    end
  end
end
