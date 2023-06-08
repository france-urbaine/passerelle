# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::TwoFactorSettingsController#create" do
  subject(:request) do
    post "/compte/2fa", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: { otp_method: "email" } }) }

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to collectivity user"
  it_behaves_like "it allows access to collectivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in(reload_tracked_fields: true) }

    context "when organization doesn't allows 2FA via email" do
      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to("/compte/2fa/edit") }
    end

    context "when organization allows 2FA via email" do
      before do
        current_user.organization.update(allow_2fa_via_email: true)
      end

      context "with 2FA method selected", params: { user: { otp_method: "2fa" } } do
        it { expect(response).to have_http_status(:redirect) }
        it { expect(response).to redirect_to("/compte/2fa/edit?otp_method=2fa") }
      end

      context "with email method selected", params: { user: { otp_method: "email" } } do
        it { expect(response).to have_http_status(:redirect) }
        it { expect(response).to redirect_to("/compte/2fa/edit?otp_method=email") }

        it "doesn't update the OTP settings" do
          expect { request and current_user.reload }
            .to  not_change(current_user, :updated_at)
            .and not_change(current_user, :otp_method).from("2fa")
        end
      end
    end
  end
end
