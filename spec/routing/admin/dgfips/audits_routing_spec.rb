# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPs::AuditsController do
  it { expect(get:    "/admin/dgfips/9c6c00c4/audits").to be_unroutable }

  it { expect(get:    "/admin/dgfip/audits").to route_to("admin/dgfips/audits#index") }
  it { expect(post:   "/admin/dgfip/audits").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/audits").to be_unroutable }
  it { expect(delete: "/admin/dgfip/audits").to be_unroutable }
end
