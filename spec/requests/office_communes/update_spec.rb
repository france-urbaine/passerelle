# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficeCommunesController#edit" do
  subject(:request) do
    patch "/guichets/#{office.id}/communes", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { office_communes: updated_attributes } }

  let!(:office) { create(:office) }

  let!(:departement) { office.ddfip.departement }
  let!(:communes)    { create_list(:commune, 3, departement: departement) }

  let(:updated_attributes) do
    { commune_codes: communes.map(&:code_insee) }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "updates the communes associated to the office" do
        expect {
          request
          office.communes.reload
        }.to change {
          # Because default order is unpredictable.
          # We sort them by ID to avoid flacky test
          office.communes.sort_by(&:id)
        }.from([])
          .to(communes.sort_by(&:id))
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the office is missing" do
      let(:office)      { Office.new(id: Faker::Internet.uuid) }
      let(:departement) { create(:departement) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
