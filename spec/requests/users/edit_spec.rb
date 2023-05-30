# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#edit" do
  subject(:request) do
    get "/utilisateurs/#{user.id}/edit", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:user) { create(:user) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to colletivity user"
    it_behaves_like "it denies access to colletivity admin"
    it_behaves_like "it allows access to super admin"

    context "when user organization is the same as current user" do
      let(:user) { create(:user, organization: current_user.organization) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to colletivity admin"

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to colletivity user"
    end

    context "when user is member of a collectivity owned by current user publisher organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }
      let(:user)         { create(:user, organization: collectivity) }

      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher user"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the user is active" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is discarded" do
      before { user.discard }

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
  end
end
