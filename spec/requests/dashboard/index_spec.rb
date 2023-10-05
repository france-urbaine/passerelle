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

    let_it_be(:packages) do
      {
        unresolved:       create(:package, collectivity: collectivities[0]),
        sandbox:          create(:package, :sandbox,  collectivity: collectivities[0]),
        assigned:         create(:package, :assigned, collectivity: collectivities[0]),
        another_assigned: create(:package, :assigned, collectivity: collectivities[1])
      }
    end

    let_it_be(:reports) do
      {
        incomplete:   create(:report, :made_for_office,             collectivity: collectivities[0], office: offices[0]),
        completed:    create(:report, :made_for_office,             collectivity: collectivities[0], office: offices[0]),
        discarded:    create(:report, :made_for_office, :discarded, collectivity: collectivities[0], office: offices[0]),

        transmitted:            create(:report, :made_for_office, :transmitted,             collectivity: collectivities[0], office: offices[0], package: packages[:unresolved]),
        transmitted_discarded:  create(:report, :made_for_office, :transmitted, :discarded, collectivity: collectivities[0], office: offices[0], package: packages[:unresolved]),
        transmitted_to_sandbox: create(:report, :made_for_office, :transmitted, :sandbox,   collectivity: collectivities[0], office: offices[0], package: packages[:sandbox]),

        pending:  create(:report, :assigned_to_office,            collectivity: collectivities[0], office: offices[0], package: packages[:assigned]),
        approved: create(:report, :assigned_to_office, :approved, collectivity: collectivities[0], office: offices[0], package: packages[:assigned]),
        rejected: create(:report, :assigned_to_office, :rejected, collectivity: collectivities[0], office: offices[0], package: packages[:assigned]),
        debated:  create(:report, :assigned_to_office, :debated,  collectivity: collectivities[0], office: offices[0], package: packages[:assigned]),

        another_pending:  create(:report, :assigned_to_office,            collectivity: collectivities[1], office: offices[1], package: packages[:another_assigned]),
        another_approved: create(:report, :assigned_to_office, :approved, collectivity: collectivities[1], office: offices[1], package: packages[:another_assigned]),
        another_rejected: create(:report, :assigned_to_office, :rejected, collectivity: collectivities[1], office: offices[1], package: packages[:another_assigned]),
        another_debated:  create(:report, :assigned_to_office, :debated,  collectivity: collectivities[1], office: offices[1], package: packages[:another_assigned])
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
            expect(response.parsed_body).to     include(dom_id(reports[:incomplete]))
            expect(response.parsed_body).to     include(dom_id(reports[:completed]))
            expect(response.parsed_body).not_to include(dom_id(reports[:discarded]))

            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_discarded]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_to_sandbox]))

            expect(response.parsed_body).not_to include(dom_id(reports[:pending]))
            expect(response.parsed_body).to     include(dom_id(reports[:approved]))
            expect(response.parsed_body).to     include(dom_id(reports[:rejected]))
            expect(response.parsed_body).to     include(dom_id(reports[:debated]))

            expect(response.parsed_body).not_to include(dom_id(reports[:another_pending]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_approved]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_rejected]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_debated]))
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

        it "returns only accessible reports" do
          pending "Not implemented"

          aggregate_failures do
            expect(response.parsed_body).to     include(dom_id(package[:unresolved]))
            expect(response.parsed_body).not_to include(dom_id(package[:sandbox]))
            expect(response.parsed_body).not_to include(dom_id(package[:assigned]))
            expect(response.parsed_body).not_to include(dom_id(package[:another_assigned]))
          end
        end

        it "returns only pending reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(dom_id(reports[:incomplete]))
            expect(response.parsed_body).not_to include(dom_id(reports[:completed]))
            expect(response.parsed_body).not_to include(dom_id(reports[:discarded]))

            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_discarded]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_to_sandbox]))

            expect(response.parsed_body).to     include(dom_id(reports[:pending]))
            expect(response.parsed_body).not_to include(dom_id(reports[:approved]))
            expect(response.parsed_body).not_to include(dom_id(reports[:rejected]))
            expect(response.parsed_body).not_to include(dom_id(reports[:debated]))

            expect(response.parsed_body).to     include(dom_id(reports[:another_pending]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_approved]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_rejected]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_debated]))
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

        it "returns only pending reports" do
          aggregate_failures do
            expect(response.parsed_body).not_to include(dom_id(reports[:incomplete]))
            expect(response.parsed_body).not_to include(dom_id(reports[:completed]))
            expect(response.parsed_body).not_to include(dom_id(reports[:discarded]))

            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_discarded]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_to_sandbox]))

            expect(response.parsed_body).to     include(dom_id(reports[:pending]))
            expect(response.parsed_body).not_to include(dom_id(reports[:approved]))
            expect(response.parsed_body).not_to include(dom_id(reports[:rejected]))
            expect(response.parsed_body).not_to include(dom_id(reports[:debated]))

            expect(response.parsed_body).not_to include(dom_id(reports[:another_pending]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_approved]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_rejected]))
            expect(response.parsed_body).not_to include(dom_id(reports[:another_debated]))
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
            expect(response.parsed_body).not_to include(dom_id(reports[:incomplete]))
            expect(response.parsed_body).not_to include(dom_id(reports[:completed]))
            expect(response.parsed_body).not_to include(dom_id(reports[:discarded]))

            expect(response.parsed_body).to     include(dom_id(reports[:transmitted]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_discarded]))
            expect(response.parsed_body).not_to include(dom_id(reports[:transmitted_to_sandbox]))

            expect(response.parsed_body).to     include(dom_id(reports[:pending]))
            expect(response.parsed_body).to     include(dom_id(reports[:approved]))
            expect(response.parsed_body).to     include(dom_id(reports[:rejected]))
            expect(response.parsed_body).to     include(dom_id(reports[:debated]))

            expect(response.parsed_body).to     include(dom_id(reports[:another_pending]))
            expect(response.parsed_body).to     include(dom_id(reports[:another_approved]))
            expect(response.parsed_body).to     include(dom_id(reports[:another_rejected]))
            expect(response.parsed_body).to     include(dom_id(reports[:another_debated]))
          end
        end
      end
    end
  end
end
