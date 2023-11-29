# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::HomeController#index", :api do
  subject(:request) do
    get "/", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata.fetch(:as, :json) }
  let(:headers) { |e| e.metadata.fetch(:headers, {}).merge(authorization_header) }
  let(:params)  { |e| e.metadata.fetch(:params, {}) }

  describe "authorizations" do
    it_behaves_like "it allows access"
    it_behaves_like "it requires to be signed in in HTML"
  end

  describe "responses" do
    it "returns nothing but still a success" do
      expect(response)
        .to have_http_status(:no_content)
        .and have_empty_body
    end
  end
end
