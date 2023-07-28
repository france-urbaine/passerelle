# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::UsersController do
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs").to route_to("organization/collectivities/users#index", collectivity_id: "9c6c00c4") }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs").to route_to("organization/collectivities/users#create", collectivity_id: "9c6c00c4") }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs").to route_to("organization/collectivities/users#destroy_all", collectivity_id: "9c6c00c4") }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/new").to       route_to("organization/collectivities/users#new", collectivity_id: "9c6c00c4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/remove").to    route_to("organization/collectivities/users#remove_all", collectivity_id: "9c6c00c4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/undiscard").to route_to("organization/collectivities/users#undiscard_all", collectivity_id: "9c6c00c4") }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4").to route_to("organization/collectivities/users#show", collectivity_id: "9c6c00c4", id: "b12170f4") }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4").to route_to("organization/collectivities/users#update", collectivity_id: "9c6c00c4", id: "b12170f4") }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4").to route_to("organization/collectivities/users#destroy", collectivity_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/edit").to      route_to("organization/collectivities/users#edit", collectivity_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/remove").to    route_to("organization/collectivities/users#remove", collectivity_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/undiscard").to route_to("organization/collectivities/users#undiscard", collectivity_id: "9c6c00c4", id: "b12170f4") }
end
