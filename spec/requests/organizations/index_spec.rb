# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OrganizationsController#index" do
  subject(:request) do
    get "/organisations", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { q: "" }) }
  let(:xhr)     { |e| e.metadata[:xhr] }

  before do
    create_list(:collectivity, 2)
    create_list(:ddfip, 2)
    create_list(:publisher, 2)
  end

  it_behaves_like "it requires to be signed in in HTML"
  it_behaves_like "it requires to be signed in in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it denies access to DDFIP user"
  it_behaves_like "it denies access to DDFIP admin"
  it_behaves_like "it denies access to publisher user"
  it_behaves_like "it denies access to publisher admin"
  it_behaves_like "it denies access to collectivity user"
  it_behaves_like "it denies access to collectivity admin"

  it_behaves_like "it responds with not acceptable to super admin"

  context "when requesting Turbo-Frame", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
    context "when signed in as a super admin" do
      before { sign_in_as(:super_admin) }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_partial_html.to match(%r{\A<li.*</li>\Z}) }
    end
  end
end
