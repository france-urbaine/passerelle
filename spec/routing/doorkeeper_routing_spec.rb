# frozen_string_literal: true

require "rails_helper"

RSpec.describe Doorkeeper::Engine, :api do
  context "with API subdomain" do
    it { expect(get:    "http://api.example.com/oauth/authorize").to route_to("doorkeeper/authorizations#new") }
    it { expect(post:   "http://api.example.com/oauth/authorize").to route_to("doorkeeper/authorizations#create") }
    it { expect(patch:  "http://api.example.com/oauth/authorize").to be_unroutable }
    it { expect(delete: "http://api.example.com/oauth/authorize").to route_to("doorkeeper/authorizations#destroy") }

    it { expect(get:    "http://api.example.com/oauth/authorize/native").to route_to("doorkeeper/authorizations#show") }
    it { expect(post:   "http://api.example.com/oauth/authorize/native").to be_unroutable }
    it { expect(patch:  "http://api.example.com/oauth/authorize/native").to be_unroutable }
    it { expect(delete: "http://api.example.com/oauth/authorize/native").to be_unroutable }

    it { expect(post:   "http://api.example.com/oauth/token").to      route_to("doorkeeper/tokens#create") }
    it { expect(post:   "http://api.example.com/oauth/revoke").to     route_to("doorkeeper/tokens#revoke") }
    it { expect(post:   "http://api.example.com/oauth/introspect").to route_to("doorkeeper/tokens#introspect") }
    it { expect(get:    "http://api.example.com/oauth/token/info").to route_to("doorkeeper/token_info#show") }
  end

  context "without subdomain" do
    it { expect(get:    "http://example.com/oauth/authorize").to be_unroutable }
    it { expect(post:   "http://example.com/oauth/authorize").to be_unroutable }
    it { expect(patch:  "http://example.com/oauth/authorize").to be_unroutable }
    it { expect(delete: "http://example.com/oauth/authorize").to be_unroutable }
  end
end
