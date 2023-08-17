# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PasswordsController#strengh_test" do
  subject(:request) do
    get "/password/strength_test", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { password: "azerty" }) }
  let(:xhr)     { |e| e.metadata[:xhr] }

  describe "responses" do
    context "when requesting HTML" do
      it { expect(response).to have_http_status(:not_acceptable) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when requesting turbo frame", headers: { "Turbo-Frame" => "content" }, xhr: true do
      context "when the password is present" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
        it { expect(response).to have_html_body.with_turbo_frame("password-strength-test-result") }
      end

      context "when the password is empty", params: { password: "" } do
        it { expect(response).to have_http_status(:bad_request) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end
    end
  end
end
