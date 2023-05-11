# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#index" do
  subject(:request) do
    get "/utilisateurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:users) do
    create_list(:user, 3) +
      create_list(:user, 2, :discarded)
  end

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "returns only kept users" do
      aggregate_failures do
        expect(response.parsed_body).to include(CGI.escape_html(users[0].name))
        expect(response.parsed_body).to include(CGI.escape_html(users[1].name))
        expect(response.parsed_body).to include(CGI.escape_html(users[2].name))
        expect(response.parsed_body).to not_include(CGI.escape_html(users[3].name))
      end
    end
  end

  context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "content" }, xhr: true do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body.with_turbo_frame("content") }
  end

  context "when requesting autocompletion", headers: { "Accept-Variant" => "autocomplete" }, xhr: true do
    it { expect(response).to have_http_status(:not_implemented) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
