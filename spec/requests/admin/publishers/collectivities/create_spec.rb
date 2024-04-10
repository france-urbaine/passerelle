# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Publishers::CollectivitiesController#create" do
  subject(:request) do
    post "/admin/editeurs/#{publisher.id}/collectivites", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { collectivity: attributes }) }

  let!(:epci)      { create(:epci) }
  let!(:publisher) { create(:publisher) }

  let(:attributes) do
    {
      territory_type:     epci.class.name,
      territory_id:       epci.id,
      name:               "Nouvelle collectivité",
      siren:              Faker::Company.unique.french_siren_number,
      contact_first_name: Faker::Name.first_name,
      contact_last_name:  Faker::Name.last_name,
      contact_email:      Faker::Internet.email,
      contact_phone:      Faker::PhoneNumber.phone_number
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the publisher is the current organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
      it { expect { request }.to change(Collectivity, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Collectivity.last).to have_attributes(
          territory:          epci,
          publisher:          publisher,
          name:               attributes[:name],
          siren:              attributes[:siren],
          contact_first_name: attributes[:contact_first_name],
          contact_last_name:  attributes[:contact_last_name],
          contact_email:      attributes[:contact_email],
          contact_phone:      attributes[:contact_phone].delete(" ")
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Une nouvelle collectivité a été ajoutée avec succés.",
          delay:  3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count) }
    end

    context "when using another publisher_id attribute" do
      let(:another_publisher) { create(:publisher) }
      let(:attributes) { super().merge(publisher_id: another_publisher.id) }

      it "ignores the attributes to assign the publisher from the URL" do
        request
        expect(Collectivity.last.publisher).to eq(publisher)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count) }
    end

    context "when the publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/editeurs/#{publisher.id}") }
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
