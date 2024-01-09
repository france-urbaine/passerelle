# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::UsersController#index" do
  subject(:request) do
    get "/organisation/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:organization) { create(%i[publisher ddfip collectivity].sample) }
  let!(:users) do
    [
      create(:user, :discarded, organization: organization),
      create(:user, :discarded),
      create(:user),
      create(:user, organization: organization),
      create(:user, :organization_admin, organization: organization)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: organization) }

    context "when requesting HTML" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "returns only kept users owned by current organization" do
        aggregate_failures do
          expect(response).to have_html_body.to have_no_text(users[0].name)
          expect(response).to have_html_body.to have_no_text(users[1].name)
          expect(response).to have_html_body.to have_no_text(users[2].name)
          expect(response).to have_html_body.to have_text(users[3].name)
          expect(response).to have_html_body.to have_text(users[4].name)
          expect(response).to have_html_body.to have_text(current_user.name)
        end
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "content" } do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("content") }
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
