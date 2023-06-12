# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TerritoriesController#edit" do
  subject(:request) do
    get "/territoires/edit", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  it_behaves_like "it requires to be signed in in HTML"
  it_behaves_like "it requires to be signed in in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it denies access to publisher user"
  it_behaves_like "it denies access to publisher admin"
  it_behaves_like "it denies access to DDFIP user"
  it_behaves_like "it denies access to DDFIP admin"
  it_behaves_like "it denies access to collectivity user"
  it_behaves_like "it denies access to collectivity admin"

  it_behaves_like "it allows access to super admin"

  context "when signed in as super admin" do
    before { sign_in_as(:super_admin) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end
end
