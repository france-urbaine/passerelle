# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Offices::UsersController#index" do
  subject(:request) do
    get "/organisation/guichets/#{office.id}/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }

  let!(:users) do
    [
      create(:user, organization: ddfip),
      create(:user, organization: ddfip, offices: [office]),
      create(:user, :discarded, organization: ddfip, offices: [office]),
      create(:user, :discarded)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to publisher super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to DDFIP admin"

    context "when the office is owned by the current organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP super admin"

      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "when requesting HTML" do
      context "when the office is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      end

      context "when the office is discarded" do
        before { office.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Ce guichet est en cours de suppression.") }
      end

      context "when the office is missing" do
        before { office.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Ce guichet n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-users" }, xhr: true do
      context "when the office is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }

        it "returns only kept members of the offices" do
          aggregate_failures do
            expect(response.parsed_body).to not_include(CGI.escape_html(users[0].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[1].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[2].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[3].name))
          end
        end
      end

      context "when the office is discarded" do
        before { office.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Ce guichet est en cours de suppression.") }
      end

      context "when the office is missing" do
        before { office.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Ce guichet n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
