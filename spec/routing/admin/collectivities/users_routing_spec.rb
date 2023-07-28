# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::UsersController do
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs").to route_to("admin/collectivities/users#index", collectivity_id: "9c6c00c4") }
  it { expect(post:   "/admin/collectivites/9c6c00c4/utilisateurs").to route_to("admin/collectivities/users#create", collectivity_id: "9c6c00c4") }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/utilisateurs").to route_to("admin/collectivities/users#destroy_all", collectivity_id: "9c6c00c4") }

  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/new").to       route_to("admin/collectivities/users#new", collectivity_id: "9c6c00c4") }
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/remove").to    route_to("admin/collectivities/users#remove_all", collectivity_id: "9c6c00c4") }
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/utilisateurs/undiscard").to route_to("admin/collectivities/users#undiscard_all", collectivity_id: "9c6c00c4") }

  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
