# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Territories::Departements::Communes#index" do
  subject(:request) do
    get "/territoires/departements/#{departement.id}/communes", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:departement) { create(:departement) }
  let!(:communes)    { create_list(:commune, 2, departement: departement) }

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
        it { expect(response).to redirect_to("/territoires/departements/#{departement.id}") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-communes" } do
      context "when the publisher is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-communes") }

        it "includes kept communes" do
          aggregate_failures do
            expect(response.parsed_body).to include(CGI.escape_html(communes[0].name))
            expect(response.parsed_body).to include(CGI.escape_html(communes[1].name))
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
