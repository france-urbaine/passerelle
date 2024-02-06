# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController do
  let(:token) { Devise.friendly_token }
  let(:id)    { SecureRandom.uuid }

  it { expect(get:    "/enregistrement/#{token}").to route_to("users/registrations#show", token:) }
  it { expect(post:   "/enregistrement/#{token}").to be_unroutable }
  it { expect(patch:  "/enregistrement/#{token}").to be_unroutable }
  it { expect(delete: "/enregistrement/#{token}").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/new").to       be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/edit").to      be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/#{id}").to be_unroutable }
  it { expect(post:   "/enregistrement/#{token}/#{id}").to be_unroutable }
  it { expect(patch:  "/enregistrement/#{token}/#{id}").to be_unroutable }
  it { expect(delete: "/enregistrement/#{token}/#{id}").to be_unroutable }
end
