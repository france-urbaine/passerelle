# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::UsersController#show" do
  subject(:request) do
    get "/organisation/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user) { create(:user) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it responds with not found to DDFIP admin"
    it_behaves_like "it responds with not found to DDFIP supervisor"
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to collectivity admin"

    context "when user organization is the current organization" do
      let(:user) { create(:user, organization: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP supervisor"
      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to collectivity user"

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to collectivity admin"
    end

    context "when user is member of a collectivity owned by current organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }
      let(:user)         { create(:user, organization: collectivity) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it responds with not found to publisher admin"
    end

    context "when user is member of a supervised office" do
      let(:user) { create(:user, offices: [current_user.offices.first], organization: current_user.organization) }

      it_behaves_like "it allows access to DDFIP supervisor"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: user.organization) }

    context "when the user is active" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is discarded" do
      before { user.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.to have_text("Cet utilisateur est en cours de suppression.") }
    end

    context "when the user is missing" do
      before { user.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.to have_text("Cet utilisateur n'a pas été trouvé ou n'existe plus.") }
    end
  end
end
