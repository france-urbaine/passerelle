# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::CollectivitiesController#index" do
  subject(:request) do
    get "/editeurs/#{publisher.id}/collectivites", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:publisher) { create(:publisher) }
  let!(:collectivities) do
    [
      create(:collectivity, :discarded, publisher: publisher),
      create(:collectivity, :discarded),
      create(:collectivity),
      create(:collectivity, publisher: publisher)
    ]
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/editeurs/#{publisher.id}") }

    context "when publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end

  context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-collectivities" }, xhr: true do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body.with_turbo_frame("datatable-collectivities") }

    it "returns only kept collectivities owned by the publisher" do
      aggregate_failures do
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[0].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[1].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(collectivities[2].name))
        expect(response.parsed_body).to include(CGI.escape_html(collectivities[3].name))
      end
    end

    context "when publisher is discarded" do
      before { publisher.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when publisher is missing" do
      before { publisher.destroy }

      it { expect(response).to have_http_status(:not_found) }
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