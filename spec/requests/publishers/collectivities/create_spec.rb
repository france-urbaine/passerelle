# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::CollectivitiesController#create" do
  subject(:request) do
    post "/editeurs/#{publisher.id}/collectivites", as:, headers:, params:
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

  context "when requesting HTML" do
    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs/#{publisher.id}") }
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
          type:  "success",
          title: "Une nouvelle collectivité a été ajoutée avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count).from(0) }
    end

    context "when using another publisher_id attribute" do
      let(:another_publisher) { create(:publisher) }

      let(:attributes) do
        super().merge(publisher_id: another_publisher.id)
      end

      it "ignores the attributes to assign the publisher from the URL" do
        request
        expect(Collectivity.last.publisher).to eq(publisher)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count).from(0) }
    end

    context "when publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs/#{publisher.id}") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Collectivity, :count).from(0) }
  end
end