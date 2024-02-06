# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationPasswordsController do
  let(:token) { Devise.friendly_token }
  let(:id)    { SecureRandom.uuid }

  it { expect(get:    "/enregistrement/#{token}/password").to be_unroutable }
  it { expect(post:   "/enregistrement/#{token}/password").to route_to("users/registration_passwords#create", token:) }
  it { expect(patch:  "/enregistrement/#{token}/password").to be_unroutable }
  it { expect(delete: "/enregistrement/#{token}/password").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/password/new").to       route_to("users/registration_passwords#new", token:) }
  it { expect(get:    "/enregistrement/#{token}/password/edit").to      be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/password/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/password/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/password/#{id}").to be_unroutable }
  it { expect(post:   "/enregistrement/#{token}/password/#{id}").to be_unroutable }
  it { expect(patch:  "/enregistrement/#{token}/password/#{id}").to be_unroutable }
  it { expect(delete: "/enregistrement/#{token}/password/#{id}").to be_unroutable }
end
