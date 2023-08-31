# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DashboardsController#index" do
  subject(:request) do
    get "/", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:departement) { create(:departement) }
  let!(:communes)    { create_list(:commune, 2, departement: departement) }

  let!(:publisher)   { create(:publisher, collectivities_count: 2, packages_transmitted_count: 3, reports_transmitted_count: 5) }

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
      create(:report, :transmitted_through_api, :sandbox, collectivity: collectivities[0], publisher: publisher),
      create(:report, :reported_through_web_ui, :discarded, collectivity: collectivities[0], publisher: publisher)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it allows access to publisher user"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
    it_behaves_like "it allows access to DDFIP user"
    it_behaves_like "it allows access to DDFIP admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      let!(:updated_by_ddfip_reports) do
        [
          create(:report, :approved, collectivity: collectivities[0], publisher: publisher),
          create(:report, :rejected, collectivity: collectivities[0], publisher: publisher),
          create(:report, :debated,  collectivity: collectivities[0], publisher: publisher)
        ]
      end

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
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[3].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[4].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[5].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[6].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[7].reference))
            expect(response.parsed_body).to include(CGI.escape_html(updated_by_ddfip_reports[0].reference))
            expect(response.parsed_body).to include(CGI.escape_html(updated_by_ddfip_reports[1].reference))
            expect(response.parsed_body).to include(CGI.escape_html(updated_by_ddfip_reports[2].reference))
          end
        end
      end

      context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "content" }, xhr: true do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("content") }
      end
    end

    context "when signed in as a publisher user" do
      before { sign_in_as(organization: publisher) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as a DDFIP user" do
      let(:ddfip) { create(:ddfip, departement: departement) }
      let(:reports) do
        attributes = {
          ddfip:        ddfip,
          collectivity: collectivities[0],
          publisher:    publisher,
          form_type:    "evaluation_local_habitation"
        }

        [
          create(:report, :transmitted_to_ddfip,      **attributes),
          create(:report, :package_approved_by_ddfip, **attributes)
        ]
      end

      before do
        sign_in_as(organization: ddfip)
        create(:office, :evaluation_local_habitation,
          ddfip:       ddfip,
          communes:    [communes[0]],
          users:       [current_user])
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[0].reference))
            expect(response.parsed_body).to include(CGI.escape_html(reports[1].reference))
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
          create(:report, :package_approved_by_ddfip, ddfip: ddfip, collectivity: collectivities[0], publisher: publisher),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], publisher: publisher, package_sandbox: true)
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
            expect(response.parsed_body).to     include(CGI.escape_html(reports[2].reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(reports[3].reference))
          end
        end
      end
    end
  end
end
