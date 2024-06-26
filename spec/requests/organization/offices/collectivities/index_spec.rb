# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Offices::CollectivitiesController#index" do
  subject(:request) do
    get "/organisation/guichets/#{office.id}/collectivites", as:, headers:, params:, xhr:
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

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to publisher super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to DDFIP admin"

    context "when the office is owned by the current organization" do
      let(:office) { create(:office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP super admin"

      it_behaves_like "it allows access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "when requesting HTML" do
      context "when the office is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/organisation/guichets/#{office.id}") }
      end

      context "when the office is discarded" do
        before { office.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce guichet est en cours de suppression.") }
      end

      context "when the office is missing" do
        before { office.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce guichet n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-collectivities" } do
      context "when the office is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-collectivities") }
      end

      it "returns only kept collectivities on the territory assigned to the office" do
        aggregate_failures do
          expect(response).to have_html_body.to have_no_text(collectivities[0].name)
          expect(response).to have_html_body.to have_text(collectivities[1].name)
          expect(response).to have_html_body.to have_no_text(collectivities[2].name)
          expect(response).to have_html_body.to have_text(collectivities[3].name)
          expect(response).to have_html_body.to have_no_text(collectivities[4].name)
        end
      end

      context "when the office is discarded" do
        before { office.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce guichet est en cours de suppression.") }
      end

      context "when the office is missing" do
        before { office.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Ce guichet n'a pas été trouvé ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
