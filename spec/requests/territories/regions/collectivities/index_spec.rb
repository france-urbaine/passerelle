# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Territories::Regions::Collectivities#index" do
  subject(:request) do
    get "/territoires/regions/#{region.id}/collectivites", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:region)       { create(:region) }
  let!(:departement)  { create(:departement, region: region) }
  let!(:commune)      { create(:commune, departement: departement) }
  let!(:collectivities) do
    [
      create(:collectivity, territory: commune),
      create(:collectivity, territory: departement),
      create(:collectivity)
    ]
  end

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
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the publisher is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/territoires/regions/#{region.id}") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-collectivities" } do
      context "when the publisher is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-collectivities") }

        it "includes kept collectivities" do
          aggregate_failures do
            expect(response).to have_html_body.to have_text(collectivities[0].name)
            expect(response).to have_html_body.to have_text(collectivities[1].name)
            expect(response).to have_html_body.to have_no_text(collectivities[2].name)
          end
        end
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
