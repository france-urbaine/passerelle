# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OauthApplicationsController#update" do
  subject(:request) do
    patch "/organisation/oauth_applications/#{oauth_application.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { oauth_application: attributes }) }

  let!(:oauth_application) { create(:oauth_application, name: "Fiscalité & Territoire") }

  let(:attributes) do
    { name: "Solutions & Territoire" }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to DGFIP super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    context "when the oauth_application is owned by the current organization" do
      let(:oauth_application) { create(:oauth_application, owner: current_user.organization) }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: oauth_application.owner) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }

      it "updates the oauth_application" do
        expect { request and oauth_application.reload }
          .to  change(oauth_application, :updated_at)
          .and change(oauth_application, :name).to("Solutions & Territoire")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end
    end

    context "when assigning another owner in attributes" do
      let(:another_publisher) { create(:publisher) }
      let(:attributes)        { super().merge(owner_id: another_publisher.id) }

      it "ignores the attributes to assign the owner from the URL" do
        expect { request and oauth_application.reload }
          .not_to change(oauth_application, :owner_id)
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and oauth_application.reload }.not_to change(oauth_application, :updated_at) }
      it { expect { request and oauth_application.reload }.not_to change(oauth_application, :name) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect(flash).to have_flash_notice }
      it { expect { request and oauth_application.reload }.not_to change(oauth_application, :updated_at) }
    end

    context "when the oauth_application is discarded" do
      before { oauth_application.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the oauth_application is missing" do
      before { oauth_application.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
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
