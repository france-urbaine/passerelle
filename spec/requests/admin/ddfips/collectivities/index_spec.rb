# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::DDFIPs::CollectivitiesController#index" do
  subject(:request) do
    get "/admin/ddfips/#{ddfip.id}/collectivites", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:departement) { create(:departement) }
  let!(:epcis)       { create_list(:epci, 3) }
  let!(:communes) do
    [
      create(:commune, epci: epcis[0]),
      create(:commune, departement: departement, epci: epcis[0]),
      create(:commune, departement: departement, epci: epcis[1]),
      create(:commune, departement: departement, epci: epcis[1]),
      create(:commune, departement: departement),
      create(:commune, epci: epcis[2]),
      create(:commune)
    ]
  end

  let!(:ddfip) { create(:ddfip, departement: departement) }
  let!(:collectivities) do
    [
      create(:collectivity, territory: epcis[0]),
      create(:collectivity, territory: epcis[1]),
      create(:collectivity, :discarded, territory: communes[4]),
      create(:collectivity, territory: communes[5])
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the DDFIP is the current organization" do
      let(:ddfip) { current_user.organization }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/ddfips/#{ddfip.id}") }
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP est en cours de suppression.") }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "datatable-collectivities" } do
      context "when the DDFIP is accessible" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-collectivities") }
      end

      it "returns only kept collectivities on the DDFIP departement territory" do
        aggregate_failures do
          expect(response).to have_html_body.to have_text(collectivities[0].name)
          expect(response).to have_html_body.to have_text(collectivities[1].name)
          expect(response).to have_html_body.to have_no_text(collectivities[2].name)
          expect(response).to have_html_body.to have_no_text(collectivities[3].name)
        end
      end

      context "when the DDFIP is discarded" do
        before { ddfip.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP est en cours de suppression.") }
      end

      context "when the DDFIP is missing" do
        before { ddfip.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Cette DDFIP n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
