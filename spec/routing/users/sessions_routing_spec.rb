# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController do
  it { expect(get:    "/connexion").to route_to("users/sessions#new") }
  it { expect(post:   "/connexion").to route_to("users/sessions#create") }
  it { expect(patch:  "/connexion").to be_unroutable }
  it { expect(delete: "/connexion").to be_unroutable }

  it { expect(get:    "/sign_out").to be_unroutable }
  it { expect(post:   "/sign_out").to be_unroutable }
  it { expect(patch:  "/sign_out").to be_unroutable }
  it { expect(delete: "/sign_out").to route_to("users/sessions#destroy") }
end
