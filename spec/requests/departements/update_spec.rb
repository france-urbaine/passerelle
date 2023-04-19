# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DepartementsController#update" do
  subject(:request) do
    patch "/departements/#{departement.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { departement: updated_attributes } }

  let!(:departement) { create(:departement, name: "VendÉe") }

  let(:updated_attributes) do
    { name: "Vendée" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/departements") }

      it "updates the departement" do
        expect {
          request
          departement.reload
        } .to change(departement, :updated_at)
          .and change(departement, :name).to("Vendée")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the departement is missing" do
      let(:departement) { Departement.new(id: Faker::Internet.uuid) }

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
      it { expect { request and departement.reload }.not_to change(departement, :updated_at) }
      it { expect { request and departement.reload }.not_to change(departement, :name) }
    end

    context "with missing departement parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/departements") }
      it { expect { request and departement.reload }.not_to change(departement, :updated_at) }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and departement.reload }.not_to change(departement, :updated_at) }
    it { expect { request and departement.reload }.not_to change(departement, :name) }
  end
end
