# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::HomeController#index" do
  subject(:request) do
    get "/", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  describe "authorizations" do
    it_behaves_like "it responds successfully in JSON"
    it_behaves_like "it responds by redirecting in HTML to", "/documentation"
  end

  describe "responses in JSON", as: :json do
    it "returns nothing but still a success" do
      expect(response)
        .to have_http_status(:no_content)
        .and have_empty_body
    end
  end
end
