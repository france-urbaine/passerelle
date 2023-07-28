# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::UsersController do
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs").to route_to("admin/publishers/users#index", publisher_id: "9c6c00c4") }
  it { expect(post:   "/admin/editeurs/9c6c00c4/utilisateurs").to route_to("admin/publishers/users#create", publisher_id: "9c6c00c4") }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/utilisateurs").to route_to("admin/publishers/users#destroy_all", publisher_id: "9c6c00c4") }

  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/new").to       route_to("admin/publishers/users#new", publisher_id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/remove").to    route_to("admin/publishers/users#remove_all", publisher_id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/utilisateurs/undiscard").to route_to("admin/publishers/users#undiscard_all", publisher_id: "9c6c00c4") }

  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
