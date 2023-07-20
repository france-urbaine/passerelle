# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPsController do
  it { expect(get:    "/admin/ddfips").to route_to("admin/ddfips#index") }
  it { expect(post:   "/admin/ddfips").to route_to("admin/ddfips#create") }
  it { expect(patch:  "/admin/ddfips").to be_unroutable }
  it { expect(delete: "/admin/ddfips").to route_to("admin/ddfips#destroy_all") }

  it { expect(get:    "/admin/ddfips/new").to       route_to("admin/ddfips#new") }
  it { expect(get:    "/admin/ddfips/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/remove").to    route_to("admin/ddfips#remove_all") }
  it { expect(get:    "/admin/ddfips/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/undiscard").to route_to("admin/ddfips#undiscard_all") }

  it { expect(get:    "/admin/ddfips/9c6c00c4").to route_to("admin/ddfips#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/ddfips/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4").to route_to("admin/ddfips#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/ddfips/9c6c00c4").to route_to("admin/ddfips#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/ddfips/9c6c00c4/edit").to      route_to("admin/ddfips#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/remove").to    route_to("admin/ddfips#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/undiscard").to route_to("admin/ddfips#undiscard", id: "9c6c00c4") }
end
