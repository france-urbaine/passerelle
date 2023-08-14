# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PasswordsController#strengh_test" do
  subject(:request) do
    get "/password/strength_test", params: { password: password }, headers: { "Turbo-Frame" => "password-strength-test-result" }
  end

  describe "responses" do
    context "when the password is present" do
      let(:password) { "azerty" }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect(response).to have_html_body.with_turbo_frame("password-strength-test-result") }
    end

    context "when the password is blank" do
      let(:password) { "" }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
