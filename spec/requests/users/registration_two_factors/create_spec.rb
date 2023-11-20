# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::RegistrationTwoFactorsController#create" do
  subject(:request) do
    post "/enregistrement/#{token}/2fa", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: { otp_method: choosed_method } }) }

  let!(:token) { user.confirmation_token }
  let!(:user)  { create(:user, :unconfirmed) }

  let(:choosed_method) { "2fa" }

  it_behaves_like "it allows access whithout being signed in"
  it_behaves_like "it responds with not acceptable in JSON whithout being signed in"

  context "with 2FA method and organization only allows 2FA method" do
    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/edit") }

    it "keeps user unconfirmed and doesn't update its OTP settings" do
      expect { request and user.reload }
        .to  not_change(user, :confirmed_at).from(nil)
        .and not_change(user, :otp_secret)
        .and not_change(user, :otp_method)
    end
  end

  context "with email method but organization only allows 2FA method" do
    let(:choosed_method) { "email" }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/edit") }

    it "keeps user unconfirmed and doesn't update its OTP settings" do
      expect { request and user.reload }
        .to  not_change(user, :confirmed_at).from(nil)
        .and not_change(user, :otp_secret)
        .and not_change(user, :otp_method)
    end
  end

  context "with 2FA method but organization allows email method" do
    before { user.organization.update(allow_2fa_via_email: true) }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/edit?otp_method=2fa") }

    it "keeps user unconfirmed and doesn't update its OTP settings" do
      expect { request and user.reload }
        .to  not_change(user, :confirmed_at).from(nil)
        .and not_change(user, :otp_secret)
        .and not_change(user, :otp_method)
    end
  end

  context "with email method and organization allows it" do
    let(:choosed_method) { "email" }

    before { user.organization.update(allow_2fa_via_email: true) }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/edit?otp_method=email") }

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
        scheme: "error",
        header: "Cette invitation est déjà complétée, a expirée ou n'a pas été trouvée."
      )
    end
  end

  context "with alreafy confirmed token" do
    before { user.confirm }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        scheme: "error",
        header: "Cette invitation est déjà complétée, a expirée ou n'a pas été trouvée."
      )
    end
  end
end
