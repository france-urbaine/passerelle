# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::UsersController do
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs").to route_to("admin/ddfips/users#index", ddfip_id: "9c6c00c4") }
  it { expect(post:   "/admin/ddfips/9c6c00c4/utilisateurs").to route_to("admin/ddfips/users#create", ddfip_id: "9c6c00c4") }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/utilisateurs").to route_to("admin/ddfips/users#destroy_all", ddfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/new").to       route_to("admin/ddfips/users#new", ddfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/remove").to    route_to("admin/ddfips/users#remove_all", ddfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/utilisateurs/undiscard").to route_to("admin/ddfips/users#undiscard_all", ddfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
