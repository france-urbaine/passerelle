# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#update" do
  subject(:request) do
    patch "/collectivites/#{collectivity.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { collectivity: updated_attributes } }

  let!(:epci)         { create(:epci) }
  let!(:collectivity) { create(:collectivity, territory: epci, name: "Agglomération Pays Basque") }

  let(:updated_attributes) do
    { name: "CA du Pays Basque" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }

      it "updates the collectivity" do
        expect {
          request
          collectivity.reload
        }.to change(collectivity, :updated_at)
          .and change(collectivity, :name).to("CA du Pays Basque")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the collectivity is discarded" do
      let(:collectivity) { create(:collectivity, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the collectivity is missing" do
      let(:collectivity) { Collectivity.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with invalid parameters" do
      let(:updated_attributes) do
        super().merge(name: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :name) }
    end

    context "with missing collectivity parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/collectivites") }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
    end

    context "when trying to update territory with territory_id parameter", pending: "use policy to authorize update params" do
      let(:another_epci) { create(:epci) }

      let(:updated_attributes) do
        super().merge(
          territory_type: "EPCI",
          territory_id:   another_epci.id
        )
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
    end

    context "when trying to update territory with territory_code parameter", pending: "use policy to authorize update params" do
      let(:another_epci) { create(:epci) }

      let(:attributes) do
        super().merge(
          territory_type: "EPCI",
          territory_code: another_epci.siren
        )
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
    end

    context "when trying to update territory with territory_data parameter as json", pending: "use policy to authorize update params" do
      let(:attributes) do
        super().merge(
          territory_data: {
            type: "EPCI",
            id:   another_epci.id
          }.to_json
        )
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
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
    it { expect { request and collectivity.reload }.not_to change(collectivity, :updated_at) }
    it { expect { request and collectivity.reload }.not_to change(collectivity, :name) }
  end
end
