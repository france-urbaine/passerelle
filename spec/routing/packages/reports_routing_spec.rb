# frozen_string_literal: true

require "rails_helper"

RSpec.describe Packages::ReportsController do
  let(:package_id) { SecureRandom.uuid }
  let(:id)         { SecureRandom.uuid }

  it { expect(get:    "/paquets/#{package_id}/signalements").to route_to("packages/reports#index", package_id:) }
  it { expect(post:   "/paquets/#{package_id}/signalements").to be_unroutable }
  it { expect(patch:  "/paquets/#{package_id}/signalements").to be_unroutable }
  it { expect(delete: "/paquets/#{package_id}/signalements").to route_to("packages/reports#destroy_all", package_id:) }

  it { expect(get:    "/paquets/#{package_id}/signalements/new").to       be_unroutable }
  it { expect(get:    "/paquets/#{package_id}/signalements/edit").to      be_unroutable }
  it { expect(get:    "/paquets/#{package_id}/signalements/remove").to    route_to("packages/reports#remove_all", package_id:) }
  it { expect(get:    "/paquets/#{package_id}/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/#{package_id}/signalements/undiscard").to route_to("packages/reports#undiscard_all", package_id:) }

  it { expect(get:    "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/#{package_id}/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
