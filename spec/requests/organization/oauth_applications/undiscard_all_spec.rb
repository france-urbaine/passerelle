# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OauthApplicationsController#undiscard_all" do
  subject(:request) do
    patch "/organisation/oauth_applications/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publisher)          { create(:publisher) }
  let!(:oauth_applications) { create_list(:oauth_application, 3, :discarded, owner: publisher) }
  let!(:ids)                { oauth_applications.map(&:id).take(2) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to publisher super admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.to change(OauthApplication.with_discarded.discarded, :count).by(-2) }

      it "undiscards the selected oauth_applications" do
        expect {
          request
          oauth_applications.each(&:reload)
        }.to change(oauth_applications[0], :discarded_at).to(nil)
          .and change(oauth_applications[1], :discarded_at).to(nil)
          .and not_change(oauth_applications[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des applications sélectionnées a été annulée.",
          delay: 3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.to change(OauthApplication.with_discarded.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.not_to change(OauthApplication.with_discarded.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.not_to change(OauthApplication.with_discarded.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(OauthApplication.with_discarded.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://www.example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://www.example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
