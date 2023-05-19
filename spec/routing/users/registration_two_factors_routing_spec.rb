# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationTwoFactorsController do
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa").to be_unroutable }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa").to route_to("users/registration_two_factors#create", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa").to route_to("users/registration_two_factors#update", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/new").to       route_to("users/registration_two_factors#new", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/edit").to      route_to("users/registration_two_factors#edit", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ/2fa/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
