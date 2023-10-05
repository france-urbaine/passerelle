# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentationController do
  it { expect(get:    "/documentation/api").to route_to("documentation#api") }
  it { expect(post:   "/documentation").to be_unroutable }
  it { expect(patch:  "/documentation").to be_unroutable }
  it { expect(delete: "/documentation").to be_unroutable }

  it { expect(get:    "/documentation/new").to       be_unroutable }
  it { expect(get:    "/documentation/edit").to      be_unroutable }
  it { expect(get:    "/documentation/remove").to    be_unroutable }
  it { expect(get:    "/documentation/undiscard").to be_unroutable }
  it { expect(patch:  "/documentation/undiscard").to be_unroutable }

  it { expect(get:    "/documentation/api/a_propos").to         route_to("documentation#api", id: "a_propos") }
  it { expect(get:    "/documentation/api/authentification").to route_to("documentation#api", id: "authentification") }
  it { expect(get:    "/documentation/api/random_page").to      route_to("documentation#api", id: "random_page") }
end
