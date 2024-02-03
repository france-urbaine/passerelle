# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/organisations").to route_to("organizations#index") }
  it { expect(post:   "/organisations").to be_unroutable }
  it { expect(patch:  "/organisations").to be_unroutable }
  it { expect(delete: "/organisations").to be_unroutable }

  it { expect(get:    "/organisations/new").to       be_unroutable }
  it { expect(get:    "/organisations/edit").to      be_unroutable }
  it { expect(get:    "/organisations/remove").to    be_unroutable }
  it { expect(get:    "/organisations/undiscard").to be_unroutable }
  it { expect(patch:  "/organisations/undiscard").to be_unroutable }

  it { expect(get:    "/organisations/#{id}").to be_unroutable }
  it { expect(post:   "/organisations/#{id}").to be_unroutable }
  it { expect(patch:  "/organisations/#{id}").to be_unroutable }
  it { expect(delete: "/organisations/#{id}").to be_unroutable }
end
