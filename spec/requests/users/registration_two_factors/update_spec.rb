# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::RegistrationTwoFactorsController#update" do
  subject(:request) do
    put "/enregistrement/#{token}/2fa", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let!(:token) { user.confirmation_token }
  let!(:user)  { create(:user, :unconfirmed) }

  let(:attributes) do
    otp_secret = User.generate_otp_secret
    otp_code   = ROTP::TOTP.new(otp_secret).at(Time.current)

    {
      otp_method: "2fa",
      otp_secret: otp_secret,
      otp_code:   otp_code
    }
  end

  context "with valid attributes" do
    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "success",
        title: "Votre inscription est complétée. Vous pouvez dorénavant vous connecter."
      )
    end

    it "confirms user and updates its OTP settings" do
      expect { request and user.reload }
        .to  change(user, :confirmed_at).from(nil)
        .and change(user, :otp_secret)
        .and not_change(user, :otp_method).from("2fa")
    end
  end

  context "with email method but organization doesn't allows this method" do
    let(:attributes) { super().merge(otp_method: "email") }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "success",
        title: "Votre inscription est complétée. Vous pouvez dorénavant vous connecter."
      )
    end

    it "confirms user, updates its OTP secret bug keep the method to 2fa" do
      expect { request and user.reload }
        .to  change(user, :confirmed_at).from(nil)
        .and change(user, :otp_secret)
        .and not_change(user, :otp_method).from("2fa")
    end
  end

  context "with email method while organization allows it" do
    before { user.organization.update(allow_2fa_via_email: true) }

    let(:attributes) { super().merge(otp_method: "email") }

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/connexion") }

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "success",
        title: "Votre inscription est complétée. Vous pouvez dorénavant vous connecter."
      )
    end

    it "confirms user and updates its OTP settings" do
      expect { request and user.reload }
        .to  change(user, :confirmed_at).from(nil)
        .and change(user, :otp_secret)
        .and change(user, :otp_method).to("email")
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
