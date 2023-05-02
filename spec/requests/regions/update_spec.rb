# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegionsController#update" do
  subject(:request) do
    patch "/regions/#{region.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { region: updated_attributes } }

  let!(:region) { create(:region, name: "Ile de France") }

  let(:updated_attributes) do
    { name: "Ile-de-France" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/regions") }

      it "updates the region" do
        expect {
          request
          region.reload
        } .to change(region, :updated_at)
          .and change(region, :name).to("Ile-de-France")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the region is missing" do
      let(:region) { Region.new(id: Faker::Internet.uuid) }

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
      it { expect { request and region.reload }.not_to change(region, :updated_at) }
      it { expect { request and region.reload }.not_to change(region, :name) }
    end

    context "with missing region parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/regions") }
      it { expect { request and region.reload }.not_to change(region, :updated_at) }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and region.reload }.not_to change(region, :updated_at) }
    it { expect { request and region.reload }.not_to change(region, :name) }
  end
end
