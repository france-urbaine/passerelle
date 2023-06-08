# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#index" do
  subject(:request) do
    get "/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:users) do
    create_list(:user, 3) +
      create_list(:user, 2, :discarded)
  end

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to collectivity admin"
    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    context "when signed in as a super admin" do
      before { sign_in_as(:super_admin) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only kept users" do
          aggregate_failures do
            expect(response.parsed_body).to include(CGI.escape_html(users[0].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[1].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[2].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[3].name))
          end
        end
      end

      context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "content" }, xhr: true do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("content") }
      end

      context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
        it { expect(response).to have_http_status(:not_implemented) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as an organization admin" do
      let(:organization) { create(:publisher) }
      let(:users) do
        [
          create(:user, :discarded, organization: organization),
          create(:user, :discarded),
          create(:user),
          create(:user, organization: organization),
          create(:user, :organization_admin, organization: organization)
        ]
      end

      before { sign_in(users.last) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only owned and kept users" do
          aggregate_failures do
            expect(response.parsed_body).to not_include(CGI.escape_html(users[0].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[1].name))
            expect(response.parsed_body).to not_include(CGI.escape_html(users[2].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[3].name))
            expect(response.parsed_body).to include(CGI.escape_html(users[4].name))
          end
        end
      end
    end
  end
end
