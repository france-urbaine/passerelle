# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::CommunesController#update_all" do
  subject(:request) do
    patch "/guichets/#{office.id}/communes", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { office_communes: attributes }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }

  let!(:communes) { create_list(:commune, 3, departement: ddfip.departement) }

  let(:attributes) do
    { commune_codes: communes.map(&:code_insee) }
  end

  context "when requesting HTML" do
    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "updates the communes associated to the office" do
        # Because default order is unpredictable.
        # We sort them by ID to avoid flacky test
        #
        expect {
          request
          office.communes.reload
        }.to change { office.communes.sort_by(&:id) }
          .from([])
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

    context "when the office is discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { office.ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
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