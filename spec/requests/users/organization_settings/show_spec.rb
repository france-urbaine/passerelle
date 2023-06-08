# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OrganizationSettingsController#show" do
  subject(:request) do
    get "/compte/organisation", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it denies access to publisher user"
  it_behaves_like "it denies access to DDFIP user"
  it_behaves_like "it denies access to collectivity user"
  it_behaves_like "it denies access to super admin"

  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to collectivity admin"

  context "when signed in as an organization admin" do
    before { sign_in_as(:organization_admin) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end
end
