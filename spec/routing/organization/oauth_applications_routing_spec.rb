# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OauthApplicationsController do
  it { expect(get:    "/organisation/oauth_applications").to route_to("organization/oauth_applications#index") }
  it { expect(post:   "/organisation/oauth_applications").to route_to("organization/oauth_applications#create") }
  it { expect(patch:  "/organisation/oauth_applications").to be_unroutable }
  it { expect(delete: "/organisation/oauth_applications").to route_to("organization/oauth_applications#destroy_all") }

  it { expect(get:    "/organisation/oauth_applications/new").to       route_to("organization/oauth_applications#new") }
  it { expect(get:    "/organisation/oauth_applications/edit").to      be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/remove").to    route_to("organization/oauth_applications#remove_all") }
  it { expect(get:    "/organisation/oauth_applications/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/undiscard").to route_to("organization/oauth_applications#undiscard_all") }

  it { expect(get:    "/organisation/oauth_applications/9c6c00c4").to route_to("organization/oauth_applications#show", id: "9c6c00c4") }
  it { expect(post:   "/organisation/oauth_applications/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/9c6c00c4").to route_to("organization/oauth_applications#update", id: "9c6c00c4") }
  it { expect(delete: "/organisation/oauth_applications/9c6c00c4").to route_to("organization/oauth_applications#destroy", id: "9c6c00c4") }

  it { expect(get:    "/organisation/oauth_applications/9c6c00c4/edit").to      route_to("organization/oauth_applications#edit", id: "9c6c00c4") }
  it { expect(get:    "/organisation/oauth_applications/9c6c00c4/remove").to    route_to("organization/oauth_applications#remove", id: "9c6c00c4") }
  it { expect(get:    "/organisation/oauth_applications/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/9c6c00c4/undiscard").to route_to("organization/oauth_applications#undiscard", id: "9c6c00c4") }
end
