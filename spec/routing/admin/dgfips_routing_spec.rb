# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPsController do
  it { expect(get:    "/admin/dgfips").to route_to("admin/dgfips#index") }
  it { expect(post:   "/admin/dgfips").to route_to("admin/dgfips#create") }
  it { expect(patch:  "/admin/dgfips").to be_unroutable }
  it { expect(delete: "/admin/dgfips").to route_to("admin/dgfips#destroy_all") }

  it { expect(get:    "/admin/dgfips/new").to       route_to("admin/dgfips#new") }
  it { expect(get:    "/admin/dgfips/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfips/remove").to    route_to("admin/dgfips#remove_all") }
  it { expect(get:    "/admin/dgfips/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/undiscard").to route_to("admin/dgfips#undiscard_all") }

  it { expect(get:    "/admin/dgfips/9c6c00c4").to route_to("admin/dgfips#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/dgfips/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/9c6c00c4").to route_to("admin/dgfips#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/dgfips/9c6c00c4").to route_to("admin/dgfips#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/dgfips/9c6c00c4/edit").to      route_to("admin/dgfips#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/dgfips/9c6c00c4/remove").to    route_to("admin/dgfips#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/dgfips/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/9c6c00c4/undiscard").to route_to("admin/dgfips#undiscard", id: "9c6c00c4") }
end
