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

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"
    it_behaves_like "it responds with not acceptable in HTML when signed in"

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to DDFIP user"
      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to collectivity user"
      it_behaves_like "it allows access to collectivity admin"
      it_behaves_like "it allows access to super admin"
    end
  end

  describe "responses", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
    before { sign_in }

    let(:params) { { q: "" } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body.to have_selector("li") }
  end
end
