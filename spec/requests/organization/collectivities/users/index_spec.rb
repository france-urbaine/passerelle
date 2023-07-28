# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::UsersController#index" do
  subject(:request) do
    get "/organisation/collectivites/#{collectivity.id}/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let(:publisher)     { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher) }
  let!(:users) do
    [
      create(:user, :discarded, organization: collectivity),
      create(:user, :discarded, organization: publisher),
      create(:user, organization: publisher),
      create(:user, organization: collectivity),
      create(:user, :organization_admin, organization: collectivity)
    ]
  end

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

    context "when requesting HTML" do
      context "when the collectivity is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité est en cours de suppression.") }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-users" }, xhr: true do
      context "when the collectivity is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only kept users owned by collectivity" do
          aggregate_failures do
            expect(response.body).to not_include(CGI.escape_html(users[0].name))
            expect(response.body).to not_include(CGI.escape_html(users[1].name))
            expect(response.body).to not_include(CGI.escape_html(users[2].name))
            expect(response.body).to include(CGI.escape_html(users[3].name))
            expect(response.body).to include(CGI.escape_html(users[4].name))
          end
        end
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité est en cours de suppression.") }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
