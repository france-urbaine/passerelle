# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#destroy", type: :request do
  subject(:request) { delete "/utilisateurs/#{user.id}", headers: }

  let(:headers) { {} }
  let(:user)    { create(:user) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/utilisateurs") }

    it "is expected to discard the record" do
      expect {
        request
        user.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not discard the record" do
      expect {
        request
        user.reload
      }.to  not_raise_error
       .and not_change(user, :attributes)
    end
  end
end
