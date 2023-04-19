# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CommunesController#update" do
  subject(:request) do
    patch "/communes/#{commune.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { commune: updated_attributes } }

  let!(:commune) { create(:commune, name: "L'AEbergement-ClÉmenciat") }

  let(:updated_attributes) do
    { name: "L'Abergement-Clémenciat" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/communes") }

      it "updates the commune" do
        expect {
          request
          commune.reload
        } .to change(commune, :updated_at)
          .and change(commune, :name).to("L'Abergement-Clémenciat")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the commune is missing" do
      let(:commune) { Commune.new(id: Faker::Internet.uuid) }

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
      it { expect { request and commune.reload }.not_to change(commune, :updated_at) }
      it { expect { request and commune.reload }.not_to change(commune, :name) }
    end

    context "with missing commune parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/communes") }
      it { expect { request and commune.reload }.not_to change(commune, :updated_at) }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and commune.reload }.not_to change(commune, :updated_at) }
    it { expect { request and commune.reload }.not_to change(commune, :name) }
  end
end
