# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController do
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ").to route_to("users/registrations#show", token: "1J8pQn85sVxojcyeSEdZ") }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ").to be_unroutable }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ").to be_unroutable }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/new").to       be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/edit").to      be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/1J8pQn85sVxojcyeSEdZ/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/enregistrement/1J8pQn85sVxojcyeSEdZ/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/enregistrement/1J8pQn85sVxojcyeSEdZ/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/enregistrement/1J8pQn85sVxojcyeSEdZ/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
