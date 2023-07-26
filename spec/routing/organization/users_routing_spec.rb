# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::UsersController do
  it { expect(get:    "/organisation/utilisateurs").to route_to("organization/users#index") }
  it { expect(post:   "/organisation/utilisateurs").to route_to("organization/users#create") }
  it { expect(patch:  "/organisation/utilisateurs").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs").to route_to("organization/users#destroy_all") }

  it { expect(get:    "/organisation/utilisateurs/new").to       route_to("organization/users#new") }
  it { expect(get:    "/organisation/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/remove").to    route_to("organization/users#remove_all") }
  it { expect(get:    "/organisation/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/undiscard").to route_to("organization/users#undiscard_all") }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4").to route_to("organization/users#show", id: "9c6c00c4") }
  it { expect(post:   "/organisation/utilisateurs/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4").to route_to("organization/users#update", id: "9c6c00c4") }
  it { expect(delete: "/organisation/utilisateurs/9c6c00c4").to route_to("organization/users#destroy", id: "9c6c00c4") }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/edit").to      route_to("organization/users#edit", id: "9c6c00c4") }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/remove").to    route_to("organization/users#remove", id: "9c6c00c4") }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/undiscard").to route_to("organization/users#undiscard", id: "9c6c00c4") }
end
