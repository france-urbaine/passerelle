# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CommunesController#edit" do
  subject(:request) do
    get "/communes/#{commune.id}/edit", as:
  end

  let(:as) { |e| e.metadata[:as] }

  let!(:commune) { create(:commune) }

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to colletivity user"
    it_behaves_like "it denies access to colletivity admin"
    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when the commune is accessible" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the commune is missing" do
      before { commune.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
