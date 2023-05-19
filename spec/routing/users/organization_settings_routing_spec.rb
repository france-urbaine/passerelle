# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OrganizationSettingsController do
  it { expect(get:    "/compte/organisation").to route_to("users/organization_settings#show") }
  it { expect(post:   "/compte/organisation").to be_unroutable }
  it { expect(patch:  "/compte/organisation").to route_to("users/organization_settings#update") }
  it { expect(delete: "/compte/organisation").to be_unroutable }

  it { expect(get:    "/compte/organisation/new").to       be_unroutable }
  it { expect(get:    "/compte/organisation/edit").to      be_unroutable }
  it { expect(get:    "/compte/organisation/remove").to    be_unroutable }
  it { expect(get:    "/compte/organisation/undiscard").to be_unroutable }

  it { expect(get:    "/compte/organisation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/compte/organisation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/compte/organisation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/compte/organisation/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
