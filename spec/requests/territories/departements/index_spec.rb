# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Territories::DepartementsController#index" do
  subject(:request) do
    get "/territoires/departements", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    # Create a publisher user to avoid creating a random user
    # in one the expected departements or a similar departement name
    # (Midi-Pyrénées, Hautes-Pyrénées, ...)
    #
    before { sign_in_as(:super_admin, :publisher) }

    context "when requesting HTML" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      before do
        create(:departement, name: "Pyrénées-Atlantiques")
        create(:departement, name: "Gironde")
      end

      let(:params) { { q: "Pyre" } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.to have_selector("li", text: "Pyrénées-Atlantiques") }
    end
  end
end
