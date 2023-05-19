# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ddfips::OfficesController#new" do
  subject(:request) do
    get "/ddfips/#{ddfip.id}/utilisateurs/new", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:ddfip) { create(:ddfip) }

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it doesn't accept JSON when signed in"
  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to colletivity user"
  it_behaves_like "it allows access to colletivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in_as(:publisher, :organization_admin) }

    context "when the DDFIP is accessible" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is missing" do
      before { ddfip.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
