# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#create" do
  subject(:request) do
    post "/ddfips", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { ddfip: attributes } }

  let!(:departement) { create(:departement) }

  let(:attributes) do
    {
      name:             departement.name,
      code_departement: departement.code_departement
    }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request }.to change(DDFIP, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(DDFIP.last).to have_attributes(
          departement:      departement,
          name:             departement.name,
          code_departement: departement.code_departement
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Une nouvelle DDFIP a été ajoutée avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid parameters" do
      let(:attributes) do
        super().merge(code_departement: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(DDFIP, :count).from(0) }
    end

    context "with missing ddfip parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(DDFIP, :count).from(0) }
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/some/path")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/some/path") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(DDFIP, :count).from(0) }
  end
end
