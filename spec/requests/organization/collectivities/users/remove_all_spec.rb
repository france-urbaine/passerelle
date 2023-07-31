# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::UsersController#remove_all" do
  subject(:request) do
    get "/organisation/collectivites/#{collectivity.id}/utilisateurs/remove", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let(:publisher)     { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher, allow_publisher_management: true) }
  let!(:users)        { create_list(:user, 3, organization: collectivity) }
  let!(:ids)          { users.map(&:id).take(2) }

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

    context "with multiple ids" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:success) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:success) }
    end
  end
end
