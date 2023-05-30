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

  it_behaves_like "it responds with not acceptable in HTML whithout being signed in"
  it_behaves_like "it responds with not acceptable in JSON whithout being signed in"
  it_behaves_like "it responds with not acceptable in HTML when signed in"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  context "when requesting autocompletion" do
    let(:headers) { { "Accept-Variant" => "autocomplete" } }
    let(:params)  { { q: "" } }
    let(:xhr)     { true }

    it_behaves_like "it allows access whithout being signed in"
    it_behaves_like "it allows access when signed in"

    context "when signed in" do
      before { sign_in }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_partial_html.to match(%r{\A<li.*</li>\Z}) }
    end
  end
end
