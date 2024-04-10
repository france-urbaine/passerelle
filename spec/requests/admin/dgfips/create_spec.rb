# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DGFIPsController#create", skip: "Disabled because of singleton record" do
  subject(:request) do
    post "/admin/dgfip", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { dgfip: attributes }) }

  let!(:dgfip) { build(:dgfip) }

  let(:attributes) do
    {
      name:               dgfip.name,
      contact_first_name: dgfip.contact_first_name,
      contact_last_name:  dgfip.contact_last_name,
      contact_email:      dgfip.contact_email
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DGFIP user"
    it_behaves_like "it denies access to DGFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
      it { expect { request }.to change(DGFIP, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(DGFIP.last).to have_attributes(
          name:               dgfip.name,
          contact_first_name: dgfip.contact_first_name,
          contact_last_name:  dgfip.contact_last_name,
          contact_email:      dgfip.contact_email
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Une nouvelle DGFIP a été ajoutée avec succés.",
          delay:   3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(DGFIP, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(DGFIP, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/dgfip") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/some/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/some/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
