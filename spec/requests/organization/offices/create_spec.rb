# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::OfficesController#create" do
  subject(:request) do
    post "/organisation/guichets", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { office: attributes }) }

  let!(:ddfip) { create(:ddfip) }
  let(:attributes) do
    {
      name:        Faker::Company.name,
      competences: Office::COMPETENCES.sample(1)
    }
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

    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
      it { expect { request }.to change(Office, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Office.last).to have_attributes(
          ddfip:       ddfip,
          name:        attributes[:name],
          competences: attributes[:competences]
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Un nouveau guichet a été ajouté avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Office, :count).from(0) }
    end

    context "when using another ddfip_id attribute" do
      let(:another_ddfip) { create(:ddfip) }
      let(:attributes) { super().merge(ddfip_id: another_ddfip.id) }

      it "ignores the attributes to assign the DDFIP from the URL" do
        request
        expect(Office.last.ddfip).to eq(ddfip)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Office, :count).from(0) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/guichets") }
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
