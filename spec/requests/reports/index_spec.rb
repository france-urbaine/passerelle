# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#index" do
  subject(:request) do
    get "/signalements", as:, headers:, params:, xhr:
  end

  let(:as) { |e| e.metadata[:as] }
  let!(:publisher) { create(:publisher) }
  let!(:collectivities) do
    [
      create(:collectivity, publisher: publisher, territory: communes[0]),
      create(:collectivity, publisher: publisher, territory: communes[1])
    ]
  end
  let!(:reports) do
    [
      create(:report, :ready, :made_through_web_ui, collectivity: collectivities[0]),
      create(:report, :ready, :made_through_web_ui, collectivity: collectivities[1]),
      create(:report, :ready, :made_through_api,    collectivity: collectivities[0], publisher: publisher),
      create(:report, :ready, :transmitted_through_web_ui, collectivity: collectivities[0]),
      create(:report, :ready, :transmitted_through_web_ui, collectivity: collectivities[1]),
      create(:report, :ready, :transmitted_through_api,    collectivity: collectivities[0], publisher: publisher),
      create(:report, :ready, :transmitted_through_api, :sandbox, collectivity: collectivities[0], publisher: publisher),
      create(:report, :ready, :made_through_web_ui, :discarded, collectivity: collectivities[0])
    ]
  end
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let_it_be(:departement) { create(:departement) }
  let_it_be(:communes)    { create_list(:commune, 2, departement: departement) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
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
      before { sign_in_as(organization: collectivities[0]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[2]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[3]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[4]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[5]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[6]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[7]))
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

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[2]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[3]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[4]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[5]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[6]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[7]))
          end
        end
      end
    end

    context "when signed in as a DDFIP admin" do
      let(:ddfip) { create(:ddfip, departement: departement) }
      let(:reports) do
        [
          create(:report, :made_for_ddfip, ddfip: ddfip, collectivity: collectivities[0]),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0]),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], sandbox: true)
        ]
      end

      before { sign_in_as(:organization_admin, organization: ddfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[2]))
          end
        end
      end
    end

    context "when signed in as a DDFIP form admin" do
      let(:ddfip) { create(:ddfip, departement: departement) }
      let(:reports) do
        [
          create(:report, :made_for_ddfip, ddfip: ddfip, collectivity: collectivities[0]),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], form_type: "evaluation_local_habitation"),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], form_type: "creation_local_habitation"),
          create(:report, :transmitted_to_ddfip, ddfip: ddfip, collectivity: collectivities[0], sandbox: true)
        ]
      end

      before { sign_in_as(:form_admin, organization: ddfip, form_types: %w[creation_local_habitation]) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[2]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[3]))
          end
        end
      end
    end

    context "when signed in as a DDFIP user" do
      let!(:ddfip) { create(:ddfip, departement: departement) }
      let!(:office) { create(:office, :evaluation_local_habitation, ddfip:) }
      let(:reports) do
        attributes = {
          ddfip:        ddfip,
          collectivity: collectivities[0],
          form_type:    "evaluation_local_habitation"
        }

        [
          create(:report, :made_for_ddfip, **attributes),
          create(:report, :transmitted_to_ddfip, **attributes),
          create(:report, :transmitted_to_ddfip, **attributes, sandbox: true),
          create(:report, :assigned_by_ddfip, **attributes, office:),
          create(:report, :assigned_by_ddfip, **attributes, collectivity: collectivities[1]),
          create(:report, :assigned_by_ddfip, **attributes, form_type: "evaluation_local_professionnel"),
          create(:report, :assigned_by_ddfip, **attributes)
        ]
      end

      before do
        sign_in_as(organization: ddfip)
        current_user.offices << office
      end

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[2]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[3]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[4]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[5]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[6]))
          end
        end
      end
    end

    context "when signed in as a DGFIP admin" do
      let(:dgfip) { DGFIP.kept.first || create(:dgfip) }
      let(:reports) do
        [
          create(:report, :made_for_ddfip, collectivity: collectivities[0]),
          create(:report, :transmitted_to_ddfip, collectivity: collectivities[0]),
          create(:report, :transmitted_to_ddfip, collectivity: collectivities[0], sandbox: true)
        ]
      end

      before { sign_in_as(:organization_admin, organization: dgfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[2]))
          end
        end
      end
    end

    context "when signed in as a DGFIP user" do
      let(:dgfip) { DGFIP.kept.first || create(:dgfip) }
      let(:reports) do
        attributes = {
          collectivity: collectivities.sample,
          publisher:    publisher,
          form_type:    "evaluation_local_habitation"
        }

        [
          create(:report, :made_for_ddfip, **attributes),
          create(:report, :transmitted_to_ddfip, **attributes),
          create(:report, :transmitted_to_ddfip, **attributes, sandbox: true),
          create(:report, :assigned_by_ddfip, **attributes),
          create(:report, :assigned_by_ddfip, **attributes, collectivity: collectivities[1]),
          create(:report, :assigned_by_ddfip, **attributes, form_type: "evaluation_local_professionnel")
        ]
      end

      before { sign_in_as(organization: dgfip) }

      context "when requesting HTML" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body }

        it "returns only accessible reports" do
          aggregate_failures do
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[0]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[1]))
            expect(response).to have_html_body.to have_no_selector(:id, dom_id(reports[2]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[3]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[4]))
            expect(response).to have_html_body.to have_selector(:id, dom_id(reports[5]))
          end
        end
      end
    end
  end
end
