# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::UsersController do
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs").to route_to("admin/offices/users#index", office_id: "9c6c00c4") }
  it { expect(post:   "/admin/guichets/9c6c00c4/utilisateurs").to route_to("admin/offices/users#create", office_id: "9c6c00c4") }
  it { expect(patch:  "/admin/guichets/9c6c00c4/utilisateurs").to route_to("admin/offices/users#update_all", office_id: "9c6c00c4") }
  it { expect(delete: "/admin/guichets/9c6c00c4/utilisateurs").to route_to("admin/offices/users#destroy_all", office_id: "9c6c00c4") }

  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/new").to       route_to("admin/offices/users#new", office_id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/edit").to      route_to("admin/offices/users#edit_all", office_id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/remove").to    route_to("admin/offices/users#remove_all", office_id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/utilisateurs/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/guichets/9c6c00c4/utilisateurs/b12170f4").to route_to("admin/offices/users#destroy", office_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/b12170f4/remove").to    route_to("admin/offices/users#remove", office_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
