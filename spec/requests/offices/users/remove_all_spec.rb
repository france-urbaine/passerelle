# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::UsersController#remove_all" do
  subject(:request) do
    get "/guichets/#{office.id}/utilisateurs/remove", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip, users: users) }
  let!(:users)  { create_list(:user, 3, organization: ddfip) }
  let!(:ids)    { users.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it allows access to super admin"

    context "when the office is owned by the current user's DDFIP organization" do
      let(:office) { create(:office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

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

    context "when the office is discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { office.ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
