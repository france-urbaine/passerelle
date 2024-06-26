# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#show" do
  subject(:request) do
    get "/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:collectivity) { create(:collectivity) }
  let!(:transmission) { create(:transmission, :made_through_web_ui, collectivity:) }

  before do
    create_list(:report, 2, :ready, collectivity:)
  end

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
      before { sign_in(transmission.user) }

      context "when the transmission doesn't have any reports" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Vous n'avez aucun signalement en attente de transmission.") }
      end

      context "when the transmission has only one report" do
        before { create(:report, :in_active_transmission, transmission:, collectivity:) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Vous avez 1 signalement en attente de transmission.") }
      end

      context "when the transmission has multiple reports" do
        before { create_list(:report, 2, :in_active_transmission, transmission:, collectivity:) }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_media_type(:html) }
        it { expect(response).to have_html_body.to have_text("Vous avez 2 signalements en attente de transmission.") }
      end
    end
  end
end
