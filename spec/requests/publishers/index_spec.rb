# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#index" do
  subject(:request) do
    get "/editeurs", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:publishers) do
    create_list(:publisher, 3) +
      create_list(:publisher, 2, :discarded)
  end

  describe "authorizations" do
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
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "when requesting HTML" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }

      it "returns only kept publishers" do
        aggregate_failures do
          expect(response.parsed_body).to include(CGI.escape_html(publishers[0].name))
          expect(response.parsed_body).to include(CGI.escape_html(publishers[1].name))
          expect(response.parsed_body).to include(CGI.escape_html(publishers[2].name))
          expect(response.parsed_body).to not_include(CGI.escape_html(publishers[3].name))
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
  end
end
