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
    let!(:collectivities) { create_list(:collectivity, 2) }

    context "when signed in as a collectivity user" do
      let!(:included_reports) do
        [
          create(:report, :approved, collectivity: collectivities[0]),
          create(:report, :rejected, collectivity: collectivities[0]),
          create(:report, :debated,  collectivity: collectivities[0]),
          create(:report, :reported_through_web_ui, collectivity: collectivities[0])
        ]
      end

      let!(:excluded_reports) do
        [
          create(:report, :approved, collectivity: collectivities[1]),
          create(:report, :rejected, collectivity: collectivities[1]),
          create(:report, :debated,  collectivity: collectivities[1]),
          create(:report, :sandbox,  collectivity: collectivities[0]),
          create(:report, :discarded, collectivity: collectivities[0]),
          create(:report, :transmitted, collectivity: collectivities[0]),
          create(:report, :reported_through_web_ui, collectivity: collectivities[1])
        ]
      end

      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            excluded_reports.each do |report|
              expect(response.parsed_body).not_to include(CGI.escape_html(report.reference))
            end

            included_reports.each do |report|
              expect(response.parsed_body).to include(CGI.escape_html(report.reference))
            end
          end
        end
      end

      context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "content" } do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.with_turbo_frame("content") }
      end
    end

    context "when signed in as a publisher user" do
      let!(:publisher)   { create(:publisher) }

      before { sign_in_as(organization: publisher) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as a DDFIP user" do
      let(:ddfip)            { create(:ddfip) }
      let(:included_reports) { create_list(:report, 1, :assigned_to_office, ddfip: ddfip) }
      let(:excluded_reports) do
        [
          create(:report, :assigned_to_office, :approved, ddfip: ddfip, commune: included_reports.first.commune, office: included_reports.first.commune.offices.first),
          create(:report, :assigned_to_office, :sandbox, ddfip: ddfip, commune: included_reports.first.commune, office: included_reports.first.commune.offices.first),
          create(:report, :assigned_to_office, :rejected, ddfip: ddfip, commune: included_reports.first.commune, office: included_reports.first.commune.offices.first),
          create(:report, :assigned_to_office, :debated, ddfip: ddfip, commune: included_reports.first.commune, office: included_reports.first.commune.offices.first),
          create(:report, :assigned_to_office, :discarded, ddfip: ddfip, commune: included_reports.first.commune, office: included_reports.first.commune.offices.first)
        ]
      end

      before do
        sign_in_as(organization: ddfip)
        create(:office_user, office: included_reports.first.commune.offices.first, user: current_user)
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            excluded_reports.each do |report|
              expect(response.parsed_body).not_to include(CGI.escape_html(report.reference))
            end

            included_reports.each do |report|
              expect(response.parsed_body).to include(CGI.escape_html(report.reference))
            end
          end
        end
      end
    end

    context "when signed in as a DDFIP admin" do
      let(:ddfip)           { create(:ddfip) }
      let(:included_report) { create(:report, :assigned_to_office, ddfip: ddfip) }
      let(:excluded_report) { create(:report, :assigned_to_office, :approved, ddfip: ddfip, commune: included_report.commune, office: included_report.commune.offices.first) }

      before do
        sign_in_as(:organization_admin, organization: ddfip)
        create(:office_user, office: included_report.commune.offices.first, user: current_user)
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response.parsed_body).to     include(CGI.escape_html(included_report.reference))
            expect(response.parsed_body).not_to include(CGI.escape_html(excluded_report.reference))
          end
        end
      end
    end

    context "when signed in as a DGFIP" do
      let(:dgfip) { create(:dgfip) }
      let!(:included_reports) do
        [
          create(:report, :transmitted),
          create(:report, :approved),
          create(:report, :rejected),
          create(:report, :debated)
        ]
      end

      let!(:excluded_reports) do
        [
          create(:report, :transmitted, :sandbox),
          create(:report, :transmitted, discarded_at: DateTime.now),
          create(:report, :completed)
        ]
      end

      before { sign_in_as(organization: dgfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            excluded_reports.each do |report|
              expect(response.parsed_body).not_to include(CGI.escape_html(report.reference))
            end

            included_reports.each do |report|
              expect(response.parsed_body).to include(CGI.escape_html(report.reference))
            end
          end
        end
      end
    end
  end
end
