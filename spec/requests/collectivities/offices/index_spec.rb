# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collectivities::OfficesController#index" do
  subject(:request) do
    get "/collectivites/#{collectivity.id}/guichets", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:departement) { create(:departement) }
  let!(:epci)        { create(:epci) }
  let!(:communes) do
    [
      create(:commune, :with_epci, departement: departement),
      create(:commune, departement: departement, epci: epci),
      create(:commune, departement: departement, epci: epci),
      create(:commune, departement: departement)
    ]
  end

  let!(:ddfip) { create(:ddfip, departement: departement) }
  let!(:offices) do
    [
      create(:office, ddfip: ddfip, communes: [communes[0], communes[3]]),
      create(:office, ddfip: ddfip, communes: [communes[1], communes[2]]),
      create(:office, ddfip: ddfip, communes: [communes[2], communes[3]]),
      create(:office, ddfip: ddfip, communes: [])
    ]
  end

  let!(:collectivity) { create(:collectivity, territory: epci) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/collectivites/#{collectivity.id}") }

    context "when collectivity is missing" do
      before { collectivity.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when collectivity is discarded" do
      before { collectivity.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is discarded" do
      before { collectivity.publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end

  context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-offices" }, xhr: true do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body.with_turbo_frame("datatable-offices") }

    it "returns only offices assigned to the collectivity territory" do
      aggregate_failures do
        expect(response.parsed_body).to not_include(CGI.escape_html(offices[0].name))
        expect(response.parsed_body).to include(CGI.escape_html(offices[1].name))
        expect(response.parsed_body).to include(CGI.escape_html(offices[2].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(offices[3].name))
      end
    end

    context "when collectivity is discarded" do
      before { collectivity.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when collectivity is missing" do
      before { collectivity.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is discarded" do
      before { collectivity.publisher.discard }

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
