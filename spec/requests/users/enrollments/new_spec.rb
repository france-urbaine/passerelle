# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::EnrollmentsController#new" do
  subject(:request) do
    get "/inscription", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  it_behaves_like "it allows access whithout being signed in"
  it_behaves_like "it responds with not acceptable in JSON whithout being signed in"

  it { expect(response).to have_http_status(:success) }
  it { expect(response).to have_content_type(:html) }
  it { expect(response).to have_html_body }
end
