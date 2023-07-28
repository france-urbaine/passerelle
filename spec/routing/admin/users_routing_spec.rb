# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  it { expect(get:    "/admin/utilisateurs").to route_to("admin/users#index") }
  it { expect(post:   "/admin/utilisateurs").to route_to("admin/users#create") }
  it { expect(patch:  "/admin/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs").to route_to("admin/users#destroy_all") }

  it { expect(get:    "/admin/utilisateurs/new").to       route_to("admin/users#new") }
  it { expect(get:    "/admin/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/remove").to    route_to("admin/users#remove_all") }
  it { expect(get:    "/admin/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/undiscard").to route_to("admin/users#undiscard_all") }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4").to route_to("admin/users#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4").to route_to("admin/users#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4").to route_to("admin/users#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/edit").to      route_to("admin/users#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/remove").to    route_to("admin/users#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/undiscard").to route_to("admin/users#undiscard", id: "9c6c00c4") }
end
