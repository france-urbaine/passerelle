# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPsController do
  it { expect(get:    "/admin/dgfip").to route_to("admin/dgfips#show") }
  it { expect(post:   "/admin/dgfip").to be_unroutable }
  it { expect(patch:  "/admin/dgfip").to route_to("admin/dgfips#update") }
  it { expect(delete: "/admin/dgfip").to be_unroutable }

  it { expect(get:    "/admin/dgfip/new").to       be_unroutable }
  it { expect(get:    "/admin/dgfip/edit").to      route_to("admin/dgfips#edit") }
  it { expect(get:    "/admin/dgfip/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/undiscard").to be_unroutable }

  it { expect(get:    "/admin/dgfip/9c6c00c4").to be_unroutable }
  it { expect(post:   "/admin/dgfip/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/9c6c00c4").to be_unroutable }
  it { expect(delete: "/admin/dgfip/9c6c00c4").to be_unroutable }

  it { expect(get:    "/admin/dgfip/9c6c00c4/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/9c6c00c4/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/9c6c00c4/undiscard").to be_unroutable }
end
