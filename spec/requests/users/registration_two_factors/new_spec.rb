# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::RegistrationTwoFactorsController#new" do
  subject(:request) do
    get "/enregistrement/#{token}/2fa/new", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let!(:token) { user.confirmation_token }
  let!(:user)  { create(:user, :unconfirmed) }

  it_behaves_like "it allows access whithout being signed in"
  it_behaves_like "it responds with not acceptable in JSON whithout being signed in"

  context "when organization doesn't allows 2FA via email" do
    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/edit") }

    it "keeps user unconfirmed and doesn't update its OTP settings" do
      expect { request and user.reload }
        .to  not_change(user, :confirmed_at).from(nil)
        .and not_change(user, :otp_secret)
        .and not_change(user, :otp_method)
    end
  end

  context "when organization allows 2FA via email" do
    before { user.organization.update(allow_2fa_via_email: true) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "keeps user unconfirmed and doesn't update its OTP settings" do
      expect { request and user.reload }
        .to  not_change(user, :confirmed_at).from(nil)
        .and not_change(user, :otp_secret)
        .and not_change(user, :otp_method)
    end
  end

  context "with an expired token" do
    before { Timecop.freeze(1.week.from_now) }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "error",
        title: "Cette invitation est déjà complétée, a expirée ou n'a pas été trouvée."
      )
    end
  end

  context "with alreafy confirmed token" do
    before { user.confirm }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "error",
        title: "Cette invitation est déjà complétée, a expirée ou n'a pas été trouvée."
      )
    end
  end
end
