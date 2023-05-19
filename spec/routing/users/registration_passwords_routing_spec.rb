# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationPasswordsController do
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password").to be_unroutable }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ/password").to route_to("users/registration_passwords#create", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ/password").to be_unroutable }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ/password").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/new").to       route_to("users/registration_passwords#new", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/edit").to      be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ/password/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
