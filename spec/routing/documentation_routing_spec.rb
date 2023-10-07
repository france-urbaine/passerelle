# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentationController do
  context "with API subdomain" do
    before { default_routes_options subdomain: "api" }

    it { expect(get:    "http://api.example.com/documentation").to route_to("documentation#api") }
    it { expect(post:   "http://api.example.com/documentation").to be_unroutable }
    it { expect(patch:  "http://api.example.com/documentation").to be_unroutable }
    it { expect(delete: "http://api.example.com/documentation").to be_unroutable }

    it { expect(get:    "http://api.example.com/documentation/a_propos").to         route_to("documentation#api", id: "a_propos") }
    it { expect(get:    "http://api.example.com/documentation/authentification").to route_to("documentation#api", id: "authentification") }
    it { expect(get:    "http://api.example.com/documentation/random_page").to      route_to("documentation#api", id: "random_page") }
  end

  context "without subdomain" do
    it { expect(get:    "http://example.com/documentation").to be_unroutable }
    it { expect(post:   "http://example.com/documentation").to be_unroutable }
    it { expect(patch:  "http://example.com/documentation").to be_unroutable }
    it { expect(delete: "http://example.com/documentation").to be_unroutable }
  end
end
