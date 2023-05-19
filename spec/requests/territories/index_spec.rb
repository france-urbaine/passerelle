# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TerritoriesController#index" do
  subject(:request) do
    get "/territoires", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  before do
    create_list(:commune, 2)
    create_list(:epci, 2)
    create_list(:departement, 2)
    create_list(:region, 2)
  end

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it doesn't accept JSON when signed in"
  it_behaves_like "it doesn't accept HTML when signed in"

  context "when signed in" do
    before { sign_in_as(:ddfip, :organization_admin) }

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      let(:params) { { q: "" } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_partial_html.to match(%r{\A<li.*</li>\Z}) }
    end
  end
end
