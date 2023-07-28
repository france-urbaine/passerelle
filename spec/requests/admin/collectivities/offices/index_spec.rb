# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Collectivities::OfficesController#index" do
  subject(:request) do
    get "/admin/collectivites/#{collectivity.id}/guichets", as:, headers:, params:, xhr:
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

    context "when the collectivity is the current organization" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
    end

    context "when the collectivity is owned by the current organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      context "when the collectivity is accessible" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité est en cours de suppression.") }
      end

      context "when the publisher is discarded" do
        before { collectivity.publisher.discard }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/admin/collectivites/#{collectivity.id}") }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "datatable-offices" }, xhr: true do
      context "when the collectivity is accessible" do
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
      end

      context "when the collectivity is discarded" do
        before { collectivity.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité est en cours de suppression.") }
      end

      context "when the publisher is discarded" do
        before { collectivity.publisher.discard }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("datatable-offices") }
      end

      context "when the collectivity is missing" do
        before { collectivity.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Cette collectivité n'a pas été trouvée ou n'existe plus.") }
      end
    end

    context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
      it { expect(response).to have_http_status(:not_implemented) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
