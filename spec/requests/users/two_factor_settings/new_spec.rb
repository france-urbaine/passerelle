# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::TwoFactorSettingsController#new" do
  subject(:request) do
    get "/compte/2fa/new", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  it_behaves_like "it requires to be signed in in HTML"
  it_behaves_like "it requires to be signed in in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"
  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to collectivity user"
  it_behaves_like "it allows access to collectivity admin"

  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in }

    context "when organization doesn't allows 2FA via email" do
      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to("/compte/2fa/edit") }
    end

    context "when organization allows 2FA via email" do
      before do
        current_user.organization.update(allow_2fa_via_email: true)
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
