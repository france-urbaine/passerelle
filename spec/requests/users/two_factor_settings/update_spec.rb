# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::TwoFactorSettingsController#update" do
  subject(:request) do
    put "/compte/2fa", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let(:attributes) do
    otp_secret    = User.generate_otp_secret
    otp_code      = ROTP::TOTP.new(otp_secret).at(Time.current)
    user_password = (current_user || create(:user)).password

    {
      otp_method:       "2fa",
      otp_secret:       otp_secret,
      otp_code:         otp_code,
      current_password: user_password
    }
  end

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to colletivity user"
  it_behaves_like "it allows access to colletivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in(reload_tracked_fields: true) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to("/compte/parametres") }

      it "updates the curent user OTP secret" do
        expect { request and current_user.reload }
          .to  change(current_user, :updated_at)
          .and change(current_user, :otp_secret)
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "La configuration de l'authentification en 2 facteurs a été modifiée avec succés.",
          delay: 3000
        )
      end

      it "sent a notifications about change to user" do
        expect {
          request
          perform_enqueued_jobs
        }.to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Modification de vos paramètres de sécurité sur FiscaHub").to(current_user.email)
      end
    end

    context "when opting to email method" do
      let(:attributes) { super().merge(otp_method: "email") }

      before do
        current_user.organization.update(allow_2fa_via_email: true)
      end

      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to("/compte/parametres") }

      it "updates the curent user OTP secret" do
        expect { request and current_user.reload }
          .to  change(current_user, :updated_at)
          .and change(current_user, :otp_secret)
          .and change(current_user, :otp_method).to("email")
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "La configuration de l'authentification en 2 facteurs a été modifiée avec succés.",
          delay: 3000
        )
      end

      it "sent a notifications about change to user" do
        expect {
          request
          perform_enqueued_jobs
        }.to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Modification de vos paramètres de sécurité sur FiscaHub").to(current_user.email)
      end
    end

    context "with wrong OTP code" do
      let(:attributes) { super().merge(otp_code: "6582") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and current_user.reload }.not_to change(current_user, :updated_at) }
      it { expect { request and current_user.reload }.not_to change(current_user, :otp_secret) }
    end

    context "without current password" do
      let(:attributes) { super().merge(current_password: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and current_user.reload }.not_to change(current_user, :updated_at) }
      it { expect { request and current_user.reload }.not_to change(current_user, :otp_secret) }
    end

    context "when opting to email method but organization denied it" do
      let(:attributes) { super().merge(otp_method: "email") }

      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to("/compte/parametres") }
      it { expect(response).to have_html_body }

      it "updates 2FA settings but ignore OTP method" do
        expect { request and current_user.reload }
          .to  change(current_user, :updated_at)
          .and change(current_user, :otp_secret)
          .and not_change(current_user, :otp_method).from("2fa")
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and current_user.reload }.not_to change(current_user, :updated_at) }
    end
  end
end
