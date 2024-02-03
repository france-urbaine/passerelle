# frozen_string_literal: true

require "rails_helper"

RSpec.describe PackagesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/paquets").to route_to("packages#index") }
  it { expect(post:   "/paquets").to be_unroutable }
  it { expect(patch:  "/paquets").to be_unroutable }
  it { expect(delete: "/paquets").to be_unroutable }

  it { expect(get:    "/paquets/new").to       be_unroutable }
  it { expect(get:    "/paquets/edit").to      be_unroutable }
  it { expect(get:    "/paquets/remove").to    be_unroutable }
  it { expect(get:    "/paquets/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/undiscard").to be_unroutable }

  it { expect(get:    "/paquets/#{id}").to route_to("packages#show", id:) }
  it { expect(post:   "/paquets/#{id}").to be_unroutable }
  it { expect(patch:  "/paquets/#{id}").to be_unroutable }
  it { expect(delete: "/paquets/#{id}").to be_unroutable }

  it { expect(get:    "/paquets/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/paquets/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/paquets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/#{id}/undiscard").to be_unroutable }
end
