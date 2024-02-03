# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationTwoFactorsController do
  let(:token) { Devise.friendly_token }
  let(:id)    { SecureRandom.uuid }

  it { expect(get:    "/enregistrement/#{token}/2fa").to be_unroutable }
  it { expect(post:   "/enregistrement/#{token}/2fa").to route_to("users/registration_two_factors#create", token:) }
  it { expect(patch:  "/enregistrement/#{token}/2fa").to route_to("users/registration_two_factors#update", token:) }
  it { expect(delete: "/enregistrement/#{token}/2fa").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/2fa/new").to       route_to("users/registration_two_factors#new", token:) }
  it { expect(get:    "/enregistrement/#{token}/2fa/edit").to      route_to("users/registration_two_factors#edit", token:) }
  it { expect(get:    "/enregistrement/#{token}/2fa/remove").to    be_unroutable }
  it { expect(get:    "/enregistrement/#{token}/2fa/undiscard").to be_unroutable }

  it { expect(get:    "/enregistrement/#{token}/2fa/#{id}").to be_unroutable }
  it { expect(post:   "/enregistrement/#{token}/2fa/#{id}").to be_unroutable }
  it { expect(patch:  "/enregistrement/#{token}/2fa/#{id}").to be_unroutable }
  it { expect(delete: "/enregistrement/#{token}/2fa/#{id}").to be_unroutable }
end
