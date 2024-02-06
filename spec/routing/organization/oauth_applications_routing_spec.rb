# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OauthApplicationsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/organisation/oauth_applications").to route_to("organization/oauth_applications#index") }
  it { expect(post:   "/organisation/oauth_applications").to route_to("organization/oauth_applications#create") }
  it { expect(patch:  "/organisation/oauth_applications").to be_unroutable }
  it { expect(delete: "/organisation/oauth_applications").to route_to("organization/oauth_applications#destroy_all") }

  it { expect(get:    "/organisation/oauth_applications/new").to       route_to("organization/oauth_applications#new") }
  it { expect(get:    "/organisation/oauth_applications/edit").to      be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/remove").to    route_to("organization/oauth_applications#remove_all") }
  it { expect(get:    "/organisation/oauth_applications/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/undiscard").to route_to("organization/oauth_applications#undiscard_all") }

  it { expect(get:    "/organisation/oauth_applications/#{id}").to route_to("organization/oauth_applications#show", id:) }
  it { expect(post:   "/organisation/oauth_applications/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{id}").to route_to("organization/oauth_applications#update", id:) }
  it { expect(delete: "/organisation/oauth_applications/#{id}").to route_to("organization/oauth_applications#destroy", id:) }

  it { expect(get:    "/organisation/oauth_applications/#{id}/edit").to      route_to("organization/oauth_applications#edit", id:) }
  it { expect(get:    "/organisation/oauth_applications/#{id}/remove").to    route_to("organization/oauth_applications#remove", id:) }
  it { expect(get:    "/organisation/oauth_applications/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{id}/undiscard").to route_to("organization/oauth_applications#undiscard", id:) }
end
