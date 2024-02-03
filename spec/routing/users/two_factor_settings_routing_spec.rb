# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::TwoFactorSettingsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/compte/2fa").to be_unroutable }
  it { expect(post:   "/compte/2fa").to route_to("users/two_factor_settings#create") }
  it { expect(patch:  "/compte/2fa").to route_to("users/two_factor_settings#update") }
  it { expect(delete: "/compte/2fa").to be_unroutable }

  it { expect(get:    "/compte/2fa/new").to       route_to("users/two_factor_settings#new") }
  it { expect(get:    "/compte/2fa/edit").to      route_to("users/two_factor_settings#edit") }
  it { expect(get:    "/compte/2fa/remove").to    be_unroutable }
  it { expect(get:    "/compte/2fa/undiscard").to be_unroutable }

  it { expect(get:    "/compte/2fa/#{id}").to be_unroutable }
  it { expect(post:   "/compte/2fa/#{id}").to be_unroutable }
  it { expect(patch:  "/compte/2fa/#{id}").to be_unroutable }
  it { expect(delete: "/compte/2fa/#{id}").to be_unroutable }
end
