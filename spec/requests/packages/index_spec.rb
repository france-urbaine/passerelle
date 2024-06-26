# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PackagesController#index" do
  subject(:request) do
    get "/paquets", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:publisher)      { create(:publisher) }
  let!(:collectivities) { create_list(:collectivity, 2, publisher: publisher) }
  let!(:packages) do
    [
      create(:package, :with_reports, collectivity: collectivities[0]),
      create(:package, :with_reports, collectivity: collectivities[1]),
      create(:package, :with_reports, collectivity: collectivities[0], publisher: publisher),
      create(:package, :with_reports, collectivity: collectivities[1], publisher: publisher),
      create(:package, :with_reports, :discarded, collectivity: collectivities[0])
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible packages" do
          aggregate_failures do
            expect(response).to have_html_body.to have_text(packages[0].reference)
            expect(response).to have_html_body.to have_no_text(packages[1].reference)
            expect(response).to have_html_body.to have_text(packages[2].reference)
            expect(response).to have_html_body.to have_no_text(packages[3].reference)
            expect(response).to have_html_body.to have_no_text(packages[4].reference)
          end
        end
      end

      context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "content" } do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("content") }
      end

      context "when requesting autocompletion", :xhr, headers: { "Accept-Variant" => "autocomplete" } do
        it { expect(response).to have_http_status(:not_implemented) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as a publisher user" do
      before { sign_in_as(organization: publisher) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible packages" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_text(packages[0].reference)
            expect(response).to have_html_body.to have_no_text(packages[1].reference)
            expect(response).to have_html_body.to have_text(packages[2].reference)
            expect(response).to have_html_body.to have_text(packages[3].reference)
            expect(response).to have_html_body.to have_no_text(packages[4].reference)
          end
        end
      end
    end

    context "when signed in as a DDFIP" do
      let(:ddfip) { create(:ddfip) }
      let(:packages) do
        [
          create(:package, :with_reports),
          create(:package, :transmitted_to_ddfip, :with_reports, ddfip: ddfip),
          create(:package, :transmitted_to_ddfip, :with_reports)
        ]
      end

      before do
        sign_in_as(:organization_admin, organization: ddfip)
        commune = create(:commune, code_departement: ddfip.code_departement)
        packages[1].reports.update_all(code_insee: commune.code_insee)
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible packages" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_text(packages[0].reference)
            expect(response).to have_html_body.to have_text(packages[1].reference)
            expect(response).to have_html_body.to have_no_text(packages[2].reference)
          end
        end
      end
    end
  end
end
