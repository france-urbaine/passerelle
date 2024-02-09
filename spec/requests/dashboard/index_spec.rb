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
    let_it_be(:collectivities) { create_list(:collectivity, 2) }

    let_it_be(:ddfip)   { create(:ddfip) }
    let_it_be(:offices) { create_list(:office, 2, :with_communes, ddfip:) }

    let_it_be(:reports) do
      {
        incomplete:   create(:report, :made_for_office,             collectivity: collectivities[0], office: offices[0]),
        completed:    create(:report, :made_for_office,             collectivity: collectivities[0], office: offices[0]),
        discarded:    create(:report, :made_for_office, :discarded, collectivity: collectivities[0], office: offices[0]),

        transmitted:            create(:report, :made_for_office, :transmitted,             collectivity: collectivities[0], ddfip:, office: offices[0]),
        transmitted_discarded:  create(:report, :made_for_office, :transmitted, :discarded, collectivity: collectivities[0], ddfip:, office: offices[0]),
        transmitted_to_sandbox: create(:report, :made_for_office, :transmitted, :sandbox,   collectivity: collectivities[0], ddfip:, office: offices[0]),

        assigned: create(:report, :assigned_to_office,     collectivity: collectivities[0], ddfip:, office: offices[0]),
        resolved: create(:report, :resolved_as_applicable, collectivity: collectivities[0], ddfip:, office: offices[0]),
        approved: create(:report, :approved_by_ddfip,      collectivity: collectivities[0], ddfip:, office: offices[0]),
        rejected: create(:report, :rejected_by_ddfip,      collectivity: collectivities[0], ddfip:),

        another_assigned: create(:report, :assigned_to_office,     collectivity: collectivities[1], ddfip:, office: offices[1]),
        another_resolved: create(:report, :resolved_as_applicable, collectivity: collectivities[1], ddfip:, office: offices[1]),
        another_approved: create(:report, :approved_by_ddfip,      collectivity: collectivities[1], ddfip:, office: offices[1])
      }
    end

    context "when signed in as a collectivity user" do
      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:incomplete]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:completed]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:discarded]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_discarded]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_to_sandbox]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:assigned]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:resolved]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:approved]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:rejected]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_assigned]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_resolved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_approved]))
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
      before { sign_in_as(organization: collectivities[0].publisher) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end

    context "when signed in as a DDFIP admin" do
      before { sign_in_as(:organization_admin, organization: ddfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only unassigned & resolved reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:incomplete]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:completed]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:discarded]))

            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:transmitted]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_discarded]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_to_sandbox]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:assigned]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:resolved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:approved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:rejected]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_assigned]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:another_resolved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_approved]))
          end
        end
      end
    end

    context "when signed in as a DDFIP user" do
      before do
        sign_in_as(organization: ddfip)
        offices[0].users << current_user
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only assigned reports linked to user offices" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:incomplete]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:completed]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:discarded]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_discarded]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_to_sandbox]))

            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:assigned]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:resolved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:approved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:rejected]))

            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_assigned]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_resolved]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:another_approved]))
          end
        end
      end
    end

    context "when signed in as a DGFIP" do
      before { sign_in_as(:dgfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }

        it "returns all transmitted reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:incomplete]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:completed]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:discarded]))

            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:transmitted]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_discarded]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[:transmitted_to_sandbox]))

            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:assigned]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:resolved]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:approved]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:rejected]))

            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:another_assigned]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:another_resolved]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[:another_approved]))
          end
        end
      end
    end
  end
end
