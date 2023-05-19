# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::CollectivitiesController#index" do
  subject(:request) do
    get "/guichets/#{office.id}/collectivites", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }

  let!(:epcis) { create_list(:epci, 3) }
  let!(:communes) do
    [
      create(:commune, departement: ddfip.departement, epci: epcis[0]),
      create(:commune, departement: ddfip.departement, epci: epcis[1]),
      create(:commune, departement: ddfip.departement, epci: epcis[2]),
      create(:commune, departement: ddfip.departement),
      create(:commune, departement: ddfip.departement)
    ]
  end

  let!(:collectivities) do
    [
      create(:collectivity, :discarded, territory: epcis[0]),
      create(:collectivity, territory: epcis[1]),
      create(:collectivity, territory: epcis[2]),
      create(:collectivity, territory: communes[3]),
      create(:collectivity, territory: communes[4])
    ]
  end

  before do
    office.communes << communes[0]
    office.communes << communes[1]
    office.communes << communes[3]
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/guichets/#{office.id}") }

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

  context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-collectivities" }, xhr: true do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body.with_turbo_frame("datatable-collectivities") }

    it "returns only kept collectivities on the territory assigned to the office" do
      aggregate_failures do
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[0].name))
        expect(response.parsed_body).to include(CGI.escape_html(collectivities[1].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[2].name))
        expect(response.parsed_body).to include(CGI.escape_html(collectivities[3].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[4].name))
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

  context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
    it { expect(response).to have_http_status(:not_implemented) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end