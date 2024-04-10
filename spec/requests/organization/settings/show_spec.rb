# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::SettingsController#show" do
  subject(:request) do
    get "/organisation/parametres", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  describe "authorizing requests" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "when signed in" do
      it "authorizes with a policy" do
        expect { request }.to be_authorized_to(:manage?, :settings).with(Organization::SettingsPolicy)
      end
    end

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "authorized requests" do
    it_behaves_like "when signed in as admin" do
      it "responds successfully" do
        expect(response)
          .to  have_http_status(:success)
          .and have_media_type(:html)
          .and have_html_body
      end
    end
  end
end
