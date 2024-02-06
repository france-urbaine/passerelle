# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::UsersController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/organisation/utilisateurs").to route_to("organization/users#index") }
  it { expect(post:   "/organisation/utilisateurs").to route_to("organization/users#create") }
  it { expect(patch:  "/organisation/utilisateurs").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs").to route_to("organization/users#destroy_all") }

  it { expect(get:    "/organisation/utilisateurs/new").to       route_to("organization/users#new") }
  it { expect(get:    "/organisation/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/remove").to    route_to("organization/users#remove_all") }
  it { expect(get:    "/organisation/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/undiscard").to route_to("organization/users#undiscard_all") }

  it { expect(get:    "/organisation/utilisateurs/#{id}").to route_to("organization/users#show", id:) }
  it { expect(post:   "/organisation/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{id}").to route_to("organization/users#update", id:) }
  it { expect(delete: "/organisation/utilisateurs/#{id}").to route_to("organization/users#destroy", id:) }

  it { expect(get:    "/organisation/utilisateurs/#{id}/edit").to      route_to("organization/users#edit", id:) }
  it { expect(get:    "/organisation/utilisateurs/#{id}/remove").to    route_to("organization/users#remove", id:) }
  it { expect(get:    "/organisation/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{id}/undiscard").to route_to("organization/users#undiscard", id:) }
end
