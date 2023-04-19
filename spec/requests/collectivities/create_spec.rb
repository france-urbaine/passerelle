# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#create" do
  subject(:request) do
    post "/collectivites", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { collectivity: attributes } }

  let!(:epci)      { create(:epci) }
  let!(:publisher) { create(:publisher) }

  let(:attributes) do
    {
      territory_type:     epci.class.name,
      territory_id:       epci.id,
      publisher_id:       publisher.id,
      name:               "Nouvelle collectivité",
      siren:              Faker::Company.unique.french_siren_number,
      contact_first_name: Faker::Name.first_name,
      contact_last_name:  Faker::Name.last_name,
      contact_email:      Faker::Internet.email,
      contact_phone:      Faker::PhoneNumber.phone_number
    }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
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

    context "with invalid parameters" do
      let(:attributes) do
        super().merge(territory_id: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count).from(0) }
    end

    context "with missing collectivity parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Collectivity, :count).from(0) }
    end

    context "when using territory_id parameter" do
      let(:attributes) do
        super().merge(
          territory_type: territory_type,
          territory_id:   territory_id
        )
      end

      context "with a Commune as territory" do
        let!(:commune) { create(:commune) }
        let(:territory_type) { "Commune" }
        let(:territory_id)   { commune.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(commune)
        end
      end

      context "with an EPCI as territory" do
        let!(:epci) { create(:epci) }
        let(:territory_type) { "EPCI" }
        let(:territory_id)   { epci.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(epci)
        end
      end

      context "with a Departement as territory" do
        let!(:departement) { create(:departement) }
        let(:territory_type) { "Departement" }
        let(:territory_id)   { departement.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(departement)
        end
      end

      context "with a Region as territory" do
        let!(:region) { create(:region) }
        let(:territory_type) { "Region" }
        let(:territory_id)   { region.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(region)
        end
      end
    end

    context "when using territory_code parameter" do
      let(:attributes) do
        super()
          .except(:territory_id)
          .merge(
            territory_type: territory_type,
            territory_code: territory_code
          )
      end

      context "with a Commune as territory" do
        let!(:commune) { create(:commune) }
        let(:territory_type) { "Commune" }
        let(:territory_code) { commune.code_insee }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(commune)
        end
      end

      context "with an EPCI as territory" do
        let!(:epci) { create(:epci) }
        let(:territory_type) { "EPCI" }
        let(:territory_code) { epci.siren }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(epci)
        end
      end

      context "with a Departement as territory" do
        let!(:departement) { create(:departement) }
        let(:territory_type) { "Departement" }
        let(:territory_code) { departement.code_departement }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(departement)
        end
      end

      context "with a Region as territory" do
        let!(:region) { create(:region) }
        let(:territory_type) { "Region" }
        let(:territory_code) { region.code_region }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(region)
        end
      end

      context "with an invalid territory_code" do
        let(:territory_type) { "Commune" }
        let(:territory_code) { "1234" }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect { request }.not_to change(Collectivity, :count).from(0) }
      end
    end

    context "when using territory_data parameter in JSON" do
      let(:attributes) do
        super()
          .except(:territory_id)
          .merge(
            territory_data: {
              type: territory_type,
              id:   territory_id
            }.to_json
          )
      end

      context "with a Commune as territory" do
        let!(:commune) { create(:commune) }
        let(:territory_type) { "Commune" }
        let(:territory_id)   { commune.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(commune)
        end
      end

      context "with an EPCI as territory" do
        let!(:epci) { create(:epci) }
        let(:territory_type) { "EPCI" }
        let(:territory_id)   { epci.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(epci)
        end
      end

      context "with a Departement as territory" do
        let!(:departement) { create(:departement) }
        let(:territory_type) { "Departement" }
        let(:territory_id)   { departement.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(departement)
        end
      end

      context "with a Region as territory" do
        let!(:region) { create(:region) }
        let(:territory_type) { "Region" }
        let(:territory_id)   { region.id }

        it "assigns the expected territory to the new record" do
          request
          expect(Collectivity.last.territory).to eq(region)
        end
      end

      context "with an invalid territory ID" do
        let(:territory_type) { "Commune" }
        let(:territory_id)   { "1234" }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect { request }.not_to change(Collectivity, :count).from(0) }
      end
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/editeur/12345")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeur/12345") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Collectivity, :count).from(0) }
  end
end
