# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OauthApplications::AuditsController do
  let(:oauth_application_id) { SecureRandom.uuid }
  let(:id)                   { SecureRandom.uuid }

  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits").to route_to("organization/oauth_applications/audits#index", oauth_application_id:) }
  it { expect(post:   "/organisation/oauth_applications/#{oauth_application_id}/audits").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{oauth_application_id}/audits").to be_unroutable }
  it { expect(delete: "/organisation/oauth_applications/#{oauth_application_id}/audits").to be_unroutable }

  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{oauth_application_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/oauth_applications/#{oauth_application_id}/audits/#{id}/undiscard").to be_unroutable }
end
