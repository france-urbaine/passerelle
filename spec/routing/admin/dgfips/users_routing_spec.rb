# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPs::UsersController do
  it { expect(get:    "/admin/dgfips/9c6c00c4/utilisateurs").to be_unroutable }

  it { expect(get:    "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#index") }
  it { expect(post:   "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#create") }
  it { expect(patch:  "/admin/dgfip/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#destroy_all") }

  it { expect(get:    "/admin/dgfip/utilisateurs/new").to       route_to("admin/dgfips/users#new") }
  it { expect(get:    "/admin/dgfip/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/remove").to    route_to("admin/dgfips/users#remove_all") }
  it { expect(get:    "/admin/dgfip/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/undiscard").to route_to("admin/dgfips/users#undiscard_all") }

  it { expect(get:    "/admin/dgfip/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/dgfip/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/dgfip/utilisateurs/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/dgfip/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
