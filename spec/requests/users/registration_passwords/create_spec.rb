# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::RegistrationPasswordsController#new" do
  subject(:request) do
    post "/enregistrement/#{token}/password", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let!(:token) { user.confirmation_token }
  let!(:user)  { create(:user, :unconfirmed) }

  let(:attributes) do
    password = Devise.friendly_token
    { password: password, password_confirmation: password }
  end

  it_behaves_like "it allows access whithout being signed in"
  it_behaves_like "it responds with not acceptable in JSON whithout being signed in"

  context "with valid attributes" do
    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to("/enregistrement/#{token}/2fa/new") }

    it "updates the user password" do
      expect { request and user.reload }
        .to change(user, :encrypted_password)
    end

    it "keeps user unconfirmed" do
      expect { request and user.reload }
        .not_to change(user, :confirmed_at).from(nil)
    end
  end

  context "with invalid attributes" do
    let(:attributes) do
      { password: Devise.friendly_token, password_confirmation: "" }
    end

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "doesn't update the curent user" do
      expect { request and user.reload }
        .to  not_change(user, :updated_at)
        .and not_change(user, :encrypted_password)
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
