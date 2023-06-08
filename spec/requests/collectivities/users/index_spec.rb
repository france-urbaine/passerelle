# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collectivities::UsersController#index" do
  subject(:request) do
    get "/collectivites/#{collectivity.id}/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:collectivity) { create(:collectivity) }
  let!(:users) do
    [
      create(:user, :discarded, organization: collectivity),
      create(:user, :discarded),
      create(:user),
      create(:user, organization: collectivity)
    ]
  end

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

    context "when the collectivity is the organization of the current user" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when the collectivity is owned by the current user's publisher organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the collectivity is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/collectivites/#{collectivity.id}") }
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the publisher is discarded" do
        before { collectivity.publisher.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-users" }, xhr: true do
      context "when the collectivity is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-users") }

        it "returns only kept users associated to the collectivity" do
          aggregate_failures do
            expect(response.parsed_body).to not_include(CGI.escape_html(users[0].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[1].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[2].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[3].name))
          end
        end
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the publisher is discarded" do
        before { collectivity.publisher.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
