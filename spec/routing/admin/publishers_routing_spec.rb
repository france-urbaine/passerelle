# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PublishersController do
  it { expect(get:    "/admin/editeurs").to route_to("admin/publishers#index") }
  it { expect(post:   "/admin/editeurs").to route_to("admin/publishers#create") }
  it { expect(patch:  "/admin/editeurs").to be_unroutable }
  it { expect(delete: "/admin/editeurs").to route_to("admin/publishers#destroy_all") }

  it { expect(get:    "/admin/editeurs/new").to       route_to("admin/publishers#new") }
  it { expect(get:    "/admin/editeurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/remove").to    route_to("admin/publishers#remove_all") }
  it { expect(get:    "/admin/editeurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/undiscard").to route_to("admin/publishers#undiscard_all") }

  it { expect(get:    "/admin/editeurs/9c6c00c4").to route_to("admin/publishers#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/editeurs/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4").to route_to("admin/publishers#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/editeurs/9c6c00c4").to route_to("admin/publishers#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/editeurs/9c6c00c4/edit").to      route_to("admin/publishers#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/remove").to    route_to("admin/publishers#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/undiscard").to route_to("admin/publishers#undiscard", id: "9c6c00c4") }
end
