# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#show" do
  subject(:request) do
    get "/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:transmission) { create(:transmission, :made_through_web_ui) }
  let!(:report)       { create(:report, :completed, collectivity: transmission.collectivity) }
  let!(:reports)      { create_list(:report, 2, :completed, collectivity: transmission.collectivity) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in transmission.user }

      context "when the transmission doesn't have any report" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Vous n'avez aucun signalement en attente de transmission.") }
      end

      context "when the transmission has one report" do
        before do
          report.update(
            transmission: transmission,
            package: nil,
            reference: nil
          )
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Vous avez 1 signalement prêt à être transmis :") }
      end

      context "when the transmission has multiple reports" do
        before do
          reports.each do |report|
            report.update(
              transmission: transmission,
              package: nil,
              reference: nil
            )
          end
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body.to include("Vous avez 2 signalements prêts à être transmis :") }
      end
    end
  end
end
