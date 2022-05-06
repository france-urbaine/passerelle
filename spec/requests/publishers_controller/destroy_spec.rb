# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#destroy", type: :request do
  subject(:request) { delete "/publishers/#{publisher.id}", headers: }

  let(:headers)   { {} }
  let(:publisher) { create(:publisher) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/publishers") }

    it "is expected to discard the record" do
      expect {
        request
        publisher.reload
      }.to change(publisher, :discarded_at).from(nil)
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
        publisher.reload
      }.to maintain(publisher, :discarded_at).from(nil)
    end
  end
end
