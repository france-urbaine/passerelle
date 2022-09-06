# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#undiscard_all", type: :request do
  subject(:request) { patch "/utilisateurs/undiscard", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { ids: [user.id] } }
  let(:user)    { create(:user, :discarded) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/utilisateurs") }

    it "is expected to discard the record" do
      expect {
        request
        user.reload
      }.to change(user, :discarded_at).from(be_a(ActiveSupport::TimeWithZone)).to(nil)
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
      }.to maintain(user, :discarded_at).from(be_a(ActiveSupport::TimeWithZone))
    end
  end
end
