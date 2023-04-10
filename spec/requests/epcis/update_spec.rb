# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EpcisController#update" do
  subject(:request) do
    patch "/epcis/#{epci.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { epci: updated_attributes } }

  let!(:epci) { create(:epci, name: "CA d'Agen") }

  let(:updated_attributes) do
    { name: "Agglomération d'Agen" }
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/epcis") }

    it "updates the epci" do
      expect {
        request
        epci.reload
      } .to change(epci, :updated_at)
        .and change(epci, :name).to("Agglomération d'Agen")
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "success",
        title: "Les modifications ont été enregistrées avec succés.",
        delay: 3000
      )
    end

    context "with invalid parameters" do
      let(:updated_attributes) do
        super().merge(name: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and epci.reload }.not_to change(epci, :updated_at) }
      it { expect { request and epci.reload }.not_to change(epci, :name) }
    end

    context "with missing epci parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/epcis") }
      it { expect { request and epci.reload }.not_to change(epci, :updated_at) }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and epci.reload }.not_to change(epci, :updated_at) }
    it { expect { request and epci.reload }.not_to change(epci, :name) }
  end
end
