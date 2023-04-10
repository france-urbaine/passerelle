# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DdfipsController#update" do
  subject(:request) do
    patch "/ddfips/#{ddfip.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { ddfip: updated_attributes } }

  let!(:ddfip) { create(:ddfip, name: "Ddfip de Pyrénée-Atlantique") }

  let(:updated_attributes) do
    { name: "DDFIP des Pyrénées-Atlantiques" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }

      it "updates the ddfip" do
        expect {
          request
          ddfip.reload
        }.to change(ddfip, :updated_at)
          .and change(ddfip, :name).to("DDFIP des Pyrénées-Atlantiques")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid parameters" do
      let(:updated_attributes) do
        super().merge(name: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :updated_at) }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :name) }
    end

    context "with missing ddfip parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips") }
      it { expect { request and ddfip.reload }.not_to change(ddfip, :updated_at) }
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
    it { expect { request and ddfip.reload }.not_to change(ddfip, :updated_at) }
    it { expect { request and ddfip.reload }.not_to change(ddfip, :name) }
  end
end
