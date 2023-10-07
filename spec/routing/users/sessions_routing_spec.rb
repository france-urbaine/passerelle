# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController do
  before { clear_default_routes_options }

  context "without subdomain" do
    it { expect(get:    "http://example.com/connexion").to route_to("users/sessions#new") }
    it { expect(post:   "http://example.com/connexion").to route_to("users/sessions#create") }
    it { expect(patch:  "http://example.com/connexion").to be_unroutable }
    it { expect(delete: "http://example.com/connexion").to be_unroutable }

    it { expect(get:    "http://example.com/sign_out").to be_unroutable }
    it { expect(post:   "http://example.com/sign_out").to be_unroutable }
    it { expect(patch:  "http://example.com/sign_out").to be_unroutable }
    it { expect(delete: "http://example.com/sign_out").to route_to("users/sessions#destroy") }
  end

  context "with API subdomain" do
    it { expect(get:    "http://api.example.com/connexion").to route_to("users/sessions#new") }
    it { expect(post:   "http://api.example.com/connexion").to route_to("users/sessions#create") }
    it { expect(patch:  "http://api.example.com/connexion").to be_unroutable }
    it { expect(delete: "http://api.example.com/connexion").to be_unroutable }

    it { expect(get:    "http://api.example.com/sign_out").to be_unroutable }
    it { expect(post:   "http://api.example.com/sign_out").to be_unroutable }
    it { expect(patch:  "http://api.example.com/sign_out").to be_unroutable }
    it { expect(delete: "http://api.example.com/sign_out").to route_to("users/sessions#destroy") }
  end
end
