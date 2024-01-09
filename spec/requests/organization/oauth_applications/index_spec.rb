# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OauthApplicationController#index" do
  subject(:request) do
    get "/organisation/oauth_applications", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:organization) { create(:publisher) }
  let!(:oauth_applications) do
    [
      create(:oauth_application, :discarded, owner: organization),
      create(:oauth_application, :discarded),
      create(:oauth_application, :discarded),
      create(:oauth_application, owner: organization),
      create(:oauth_application, owner: organization)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DGFIP super admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to collectivity super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to publisher super admin"
    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: organization) }

    context "when requesting HTML" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "returns only kept oauth_applications owned by current organization" do
        aggregate_failures do
          expect(response).to have_html_body.to have_no_text(oauth_applications[0].name)
          expect(response).to have_html_body.to have_no_text(oauth_applications[1].name)
          expect(response).to have_html_body.to have_no_text(oauth_applications[2].name)
          expect(response).to have_html_body.to have_text(oauth_applications[3].name)
          expect(response).to have_html_body.to have_text(oauth_applications[4].name)
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
