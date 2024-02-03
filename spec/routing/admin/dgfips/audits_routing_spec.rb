# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPs::AuditsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/dgfip/audits").to route_to("admin/dgfips/audits#index") }
  it { expect(post:   "/admin/dgfip/audits").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/audits").to be_unroutable }
  it { expect(delete: "/admin/dgfip/audits").to be_unroutable }

  it { expect(get:    "/admin/dgfip/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/dgfip/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/dgfip/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/dgfip/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/dgfip/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/dgfip/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/audits/#{id}/undiscard").to be_unroutable }
end
