# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#index" do
  subject(:request) do
    get "/signalements", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:departement) { create(:departement) }
  let!(:communes)    { create_list(:commune, 2, departement: departement) }

  let!(:publisher)   { create(:publisher) }
  let!(:collectivities) do
    [
      create(:collectivity, publisher: publisher, territory: communes[0]),
      create(:collectivity, publisher: publisher, territory: communes[1])
    ]
  end

  let!(:reports) do
    [
      create(:report, :reported_through_web_ui, collectivity: collectivities[0], publisher: publisher),
      create(:report, :reported_through_web_ui, collectivity: collectivities[1], publisher: publisher),
      create(:report, :reported_through_api,    collectivity: collectivities[0], publisher: publisher),
      create(:report, :transmitted_through_web_ui, collectivity: collectivities[0], publisher: publisher),
      create(:report, :transmitted_through_web_ui, collectivity: collectivities[1], publisher: publisher),
      create(:report, :transmitted_through_api,    collectivity: collectivities[0], publisher: publisher),
      create(:report, :transmitted_through_api,    collectivity: collectivities[0], publisher: publisher, sandbox: true),
      create(:report, :reported_through_web_ui, :discarded, collectivity: collectivities[0], publisher: publisher)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to colletivity user"
    it_behaves_like "it allows access to colletivity admin"
    it_behaves_like "it allows access to DDFIP user"
    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).to     include(CGI.escape_html(reports[0].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[1].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[2].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[3].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[4].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[5].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[6].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[7].reference))
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

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[0].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[1].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[2].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[3].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[4].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[5].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[6].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[7].reference))
          end
        end
      end
    end

    context "when signed in as a DDFIP admin" do
      let(:ddfip) { create(:ddfip, departement: departement) }
      let(:reports) do
        [
          create(:report, :reported_for_ddfip,   ddfip: ddfip, collectivity: collectivities[0], publisher: publisher),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], publisher: publisher),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], publisher: publisher, sandbox: true)
        ]
      end

      before { sign_in_as(:organization_admin, organization: ddfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[0].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[1].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[2].reference))
          end
        end
      end
    end

    context "when signed in as a DDFIP user" do
      let(:ddfip) { create(:ddfip, departement: departement) }
      let(:reports) do
        attributes = {
          ddfip:        ddfip,
          collectivity: collectivities[0],
          publisher:    publisher,
          action:       "evaluation_hab"
        }

        [
          create(:report, :reported_for_ddfip,        **attributes),
          create(:report, :transmitted_to_ddfip,      **attributes),
          create(:report, :package_approved_by_ddfip, **attributes, sandbox: true),
          create(:report, :package_approved_by_ddfip, **attributes),
          create(:report, :package_approved_by_ddfip, **attributes, collectivity: collectivities[1]),
          create(:report, :package_approved_by_ddfip, **attributes, action: "evaluation_eco")
        ]
      end

      before do
        sign_in_as(organization: ddfip)
        create(:office,
          ddfip:    ddfip,
          action:   "evaluation_hab",
          communes: [communes[0]],
          users:    [current_user])
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[0].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[1].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[2].reference))
            expect(response.parsed_body).to     include(CGI.escape_html(reports[3].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[4].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[5].reference))
          end
        end
      end
    end
  end
end
