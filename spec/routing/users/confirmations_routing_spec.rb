# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::ConfirmationsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/confirmation").to route_to("users/confirmations#show") }
  it { expect(post:   "/confirmation").to route_to("users/confirmations#create") }
  it { expect(patch:  "/confirmation").to be_unroutable }
  it { expect(delete: "/confirmation").to be_unroutable }

  it { expect(get:    "/confirmation/new").to       route_to("users/confirmations#new") }
  it { expect(get:    "/confirmation/edit").to      be_unroutable }
  it { expect(get:    "/confirmation/remove").to    be_unroutable }
  it { expect(get:    "/confirmation/undiscard").to be_unroutable }

  it { expect(get:    "/confirmation/#{id}").to be_unroutable }
  it { expect(post:   "/confirmation/#{id}").to be_unroutable }
  it { expect(patch:  "/confirmation/#{id}").to be_unroutable }
  it { expect(delete: "/confirmation/#{id}").to be_unroutable }
end
