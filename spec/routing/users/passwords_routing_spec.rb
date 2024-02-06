# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::PasswordsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/password").to be_unroutable }
  it { expect(post:   "/password").to route_to("users/passwords#create") }
  it { expect(patch:  "/password").to route_to("users/passwords#update") }
  it { expect(delete: "/password").to be_unroutable }

  it { expect(get:    "/password/new").to       route_to("users/passwords#new") }
  it { expect(get:    "/password/edit").to      route_to("users/passwords#edit") }
  it { expect(get:    "/password/remove").to    be_unroutable }
  it { expect(get:    "/password/undiscard").to be_unroutable }

  it { expect(get:    "/password/#{id}").to be_unroutable }
  it { expect(post:   "/password/#{id}").to be_unroutable }
  it { expect(patch:  "/password/#{id}").to be_unroutable }
  it { expect(delete: "/password/#{id}").to be_unroutable }
end
