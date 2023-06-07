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
  let!(:collectivities) { create_list(:collectivity, 2) }
  let!(:packages) do
    [
      create(:package, collectivity: collectivities[0]),
      create(:package, collectivity: collectivities[0], publisher: publisher),
      create(:package, :transmitted, :with_reports, collectivity: collectivities[1]),
      create(:package, :transmitted, :with_reports, collectivity: collectivities[0], publisher: publisher),
      create(:package, :discarded, collectivity: collectivities[0])
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to colletivity user"
    it_behaves_like "it allows access to colletivity admin"
    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        fit "returns only accessible packages" do
          aggregate_failures do
            expect(response.parsed_body).to     include(CGI.escape_html(packages[0].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[1].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[2].name))
            expect(response.parsed_body).to     include(CGI.escape_html(packages[3].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[4].name))
          end
        end
      end

      context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "content" }, xhr: true do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("content") }
      end

      context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
        it { expect(response).to have_http_status(:not_implemented) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as a publisher user" do
      before { sign_in_as(organization: publisher) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible packages" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[0].name))
            expect(response.parsed_body).to     include(CGI.escape_html(packages[1].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[2].name))
            expect(response.parsed_body).to     include(CGI.escape_html(packages[3].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[4].name))
          end
        end
      end
    end

    context "when signed in as a DDFIP admin" do
      let(:ddfip) { create(:ddfip) }
      let(:packages) do
        [
          create(:package, :sent_to_ddfip, ddfip: ddfip),
          create(:package, :transmitted_to_ddfip, ddfip: ddfip),
          create(:package, :transmitted_to_ddfip)
        ]
      end

      before { sign_in_as(:orgnization_admin, ddfip: ddfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible packages" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[0].name))
            expect(response.parsed_body).to     include(CGI.escape_html(packages[1].name))
            expect(response.parsed_body).not_to include(CGI.escape_html(packages[2].name))
          end
        end
      end
    end
  end
end
