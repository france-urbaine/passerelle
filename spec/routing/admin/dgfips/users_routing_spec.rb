# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPs::UsersController do
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs").to route_to("admin/dgfips/users#index", dgfip_id: "9c6c00c4") }
  it { expect(post:   "/admin/dgfips/9c6c00c4/utilisateurs").to route_to("admin/dgfips/users#create", dgfip_id: "9c6c00c4") }
  it { expect(patch:  "/admin/dgfips/9c6c00c4/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/dgfips/9c6c00c4/utilisateurs").to route_to("admin/dgfips/users#destroy_all", dgfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/new").to       route_to("admin/dgfips/users#new", dgfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/remove").to    route_to("admin/dgfips/users#remove_all", dgfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/9c6c00c4/utilisateurs/undiscard").to route_to("admin/dgfips/users#undiscard_all", dgfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfips/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
