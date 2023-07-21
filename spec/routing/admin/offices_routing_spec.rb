# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::OfficesController do
  it { expect(get:    "/admin/guichets").to route_to("admin/offices#index") }
  it { expect(post:   "/admin/guichets").to route_to("admin/offices#create") }
  it { expect(patch:  "/admin/guichets").to be_unroutable }
  it { expect(delete: "/admin/guichets").to route_to("admin/offices#destroy_all") }

  it { expect(get:    "/admin/guichets/new").to       route_to("admin/offices#new") }
  it { expect(get:    "/admin/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/remove").to    route_to("admin/offices#remove_all") }
  it { expect(get:    "/admin/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/undiscard").to route_to("admin/offices#undiscard_all") }

  it { expect(get:    "/admin/guichets/9c6c00c4").to route_to("admin/offices#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/guichets/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4").to route_to("admin/offices#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/guichets/9c6c00c4").to route_to("admin/offices#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/guichets/9c6c00c4/edit").to      route_to("admin/offices#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/remove").to    route_to("admin/offices#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/undiscard").to route_to("admin/offices#undiscard", id: "9c6c00c4") }
end
