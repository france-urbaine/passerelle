# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OauthApplicationsController#create" do
  subject(:request) do
    post "/organisation/oauth_applications", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { oauth_application: attributes }) }

  let!(:publisher) { create(:publisher) }
  let(:attributes) { { name: Faker::Company.name, sandbox: false } }

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

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to publisher super admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.to change(OauthApplication, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(OauthApplication.last).to have_attributes(
          owner:   publisher,
          name:    attributes[:name],
          sandbox: false
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Une nouvelle application a été ajoutée avec succés.",
          delay:  3000
        )
      end
    end

    context "when the publisher is in sandbox" do
      before { publisher.update(sandbox: true) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/oauth_applications") }
      it { expect { request }.to change(OauthApplication, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(OauthApplication.last).to have_attributes(
          owner:   publisher,
          name:    attributes[:name],
          sandbox: false
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Une nouvelle application a été ajoutée avec succés.",
          delay:  3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(OauthApplication, :count).from(0) }
    end

    context "when using another owner_id attribute" do
      let(:another_publisher) { create(:publisher) }
      let(:attributes) { super().merge(owner_id: another_publisher.id) }

      it "ignores the attributes to assign the owner from the URL" do
        request
        expect(OauthApplication.last.owner).to eq(publisher)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(OauthApplication, :count).from(0) }
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
