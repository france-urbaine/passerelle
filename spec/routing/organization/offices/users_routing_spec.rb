# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Offices::UsersController do
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs").to route_to("organization/offices/users#index", office_id: "9c6c00c4") }
  it { expect(post:   "/organisation/guichets/9c6c00c4/utilisateurs").to route_to("organization/offices/users#create", office_id: "9c6c00c4") }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/utilisateurs").to route_to("organization/offices/users#update_all", office_id: "9c6c00c4") }
  it { expect(delete: "/organisation/guichets/9c6c00c4/utilisateurs").to route_to("organization/offices/users#destroy_all", office_id: "9c6c00c4") }

  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/new").to       route_to("organization/offices/users#new", office_id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/edit").to      route_to("organization/offices/users#edit_all", office_id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/remove").to    route_to("organization/offices/users#remove_all", office_id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/utilisateurs/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4").to route_to("organization/offices/users#destroy", office_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4/remove").to    route_to("organization/offices/users#remove", office_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/utilisateurs/b12170f4/undiscard").to be_unroutable }
end
